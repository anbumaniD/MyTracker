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
    
    // MARK: -
    
    fileprivate let coreDataManager = CoreDataManager(modelName: "MyTracker")
    
    // MARK: -
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Expense> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataManager.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Save item")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "SegueAddExpenseViewController":
            guard let navigationController = segue.destination as? UINavigationController else { return }
            guard let viewController = navigationController.viewControllers.first as? AddExpenseViewController else { return }
            // Configure View Controller
            viewController.delegate = self

        default:
            print("Unknown Segue")
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
        cell.detailTextLabel?.text = String(item.amount)
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ViewController: AddExpenseViewControllerDelegate {
    
    func controller(_ controller: AddExpenseViewController, didAddExpense title: String, amount: Double, category: String, notes: String) {
        
        // Create Item
        let item  = Expense(context: coreDataManager.managedObjectContext)
        
        // Populate Item
        item.title = title
        item.amount = amount
        item.category = category
        item.notes = notes
        item.createdAt = NSDate()
        
        do{
            try item.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print("Unable to save item")
            print("\(saveError), \(saveError.localizedDescription)")
        }
        
    }
    
}

