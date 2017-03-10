//
//  ViewController.swift
//  MyTracker
//
//  Created by Anbumani on 08/03/17.
//  Copyright © 2017 Anbu. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK:- Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - DB Manager
    
    fileprivate let coreDataManager = CoreDataManager(modelName: "MyTracker")
    
    // MARK: - Initialize fetchedresultcontroller
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Expense> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "category", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataManager.managedObjectContext, sectionNameKeyPath: "category", cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Perform fetch
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Save item")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
       
        //Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    //MARK:- Passcode handling after app went to background.
    func applicationDidEnterBackground(){
        
        showPasscodeLockScreen()
        
    }
    
    func showPasscodeLockScreen(){
        
        if (UserDefaults.standard.value(forKey: "PASSCODE") as? String) != nil {

            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let passcodeViewController = storyBoard.instantiateViewController(withIdentifier: "PasscodeViewController") as! PasscodeViewController
            navigationController?.present(passcodeViewController, animated: true, completion: nil)
            passcodeViewController.messageLabel.text = "Enter passcode to view your expenses"
 
        }
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "SegueAddExpenseViewController":
            guard let navigationController = segue.destination as? UINavigationController else { return }
            guard (navigationController.viewControllers.first as? AddExpenseViewController) != nil else { return }
            
            
        case "SegueExpenseViewController":
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let navigationController = segue.destination as? UINavigationController else { return }
            guard let viewController = navigationController.viewControllers.first as? AddExpenseViewController else { return }
            // Fetch expenseItem
            let expenseItem = fetchedResultsController.object(at: indexPath)
            
            // Configure View Controller
            viewController.item = expenseItem
            
            
        default:
            print("Unknown Segue")
        }
    }
    
    // MARK: - Segment Actions
    
    @IBAction func segmentChangedAction(_ sender: UISegmentedControl) {
        
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let dateFrom = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
        components.day! += 1
        let dateTo = calendar.date(from: components)! // eg. 2016-10-11 00:00:00
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.fetchedResultsController.fetchRequest.predicate  = nil
        case 1:
            
            // Fetch for today date
            let datePredicate = NSPredicate(format: "(%@ <= createdAt) AND (createdAt < %@)", argumentArray: [dateFrom, dateTo])
            self.fetchedResultsController.fetchRequest.predicate  = datePredicate
            
        case 2:
            // Fetch for last seven days
            let newDateFromComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
            components.day! -= 7;
            let newDateFrom = calendar.date(from: newDateFromComponents)!
            let datePredicate = NSPredicate(format: "(%@ <= createdAt) AND (createdAt < %@)", argumentArray: [newDateFrom, dateTo])
            self.fetchedResultsController.fetchRequest.predicate  = datePredicate
    
        case 3:
            // Fetch for last 30 days
            let newDateFromComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
            components.month! -= 1;
            let newDateFrom = calendar.date(from: newDateFromComponents)!
            let datePredicate = NSPredicate(format: "(%@ <= createdAt) AND (createdAt < %@)", argumentArray: [newDateFrom, dateTo])
            self.fetchedResultsController.fetchRequest.predicate  = datePredicate
       
        default:
            break;
        }
        
        do {
            try self.fetchedResultsController.performFetch()
            
        } catch {
            let fetchError = error as NSError
            print("Unable to Save item")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell, at: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
    
}
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
      
         return (fetchedResultsController.sections?.count)!
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath)
        
        // Configure Cell
        configureCell(cell, at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let sections = fetchedResultsController.sections else {
            return ""
        }
        let sectionInfo = sections[section]
        
        let header = sectionInfo.name
        var amount:Double=0.0
        for item in sectionInfo.objects! {
            amount += (item as! Expense).amount;
        }
        return "\(header) - (\(amount) ₹)";
        
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        // Fetch Item
        let item = fetchedResultsController.object(at: indexPath)
        
        // Delete Item
        fetchedResultsController.managedObjectContext.delete(item)
    }
    
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        // Fetch Item
        let item = fetchedResultsController.object(at: indexPath)
        
        // Configure Cell
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = String(item.amount)+" ₹"
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

