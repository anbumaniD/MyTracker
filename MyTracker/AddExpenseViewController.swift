//
//  AddExpenseViewController.swift
//  MyTracker
//
//  Created by Anbumani on 09/03/17.
//  Copyright © 2017 Anbu. All rights reserved.
//

import UIKit


class AddExpenseViewController: UITableViewController {

    // MARK: - Properties
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var amountField: UITextField!
    
    @IBOutlet weak var categoryField: UITextField!
    
    @IBOutlet weak var notesField: UITextView!
    
    var item: Expense?
    
    // MARK: - DB Manager
    
    fileprivate let coreDataManager = CoreDataManager(modelName: "MyTracker")
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Update the User Interface with expense item if availabel.
        
        if let item = item{
            
            nameField.text = item.title
            amountField.text = String(item.amount)
            categoryField.text = item.category
            notesField.text = item.notes
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Button Actions
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        // Dismiss View Controller
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        guard let title = nameField.text else {
            print("title not entered")
            self.showAlert(msg: "Enter title")
            return
        }
        guard let amount = amountField.text else {
            print("amount not entered")
            self.showAlert(msg: "Enter amount")
            return
        }
        guard let category = categoryField.text else {
            print("category not entered")
            self.showAlert(msg: "Enter category")
            return
        }
        
        //        guard let notes = self.notesField.text else {
        //            print("notes not entered")
        //            return
        //        }
        
        if (title.isEmpty) ||
            (amount.isEmpty) ||
            (category.isEmpty) {
            
            self.showAlert(msg: "Enter required fields")
            return
            
        }
        
        if let expItem = item{
            // Update an item
            expItem.title = title
            expItem.amount = Double(amount)!
            expItem.category = category
            expItem.notes = notesField.text
            expItem.createdAt = NSDate()
            
        }else{
            // Create new Item
            let item  = Expense(context: coreDataManager.managedObjectContext)
            item.title = title
            item.amount = Double(amount)!
            item.category = category
            item.notes = notesField.text
            item.createdAt = NSDate()
            
            //Save the new item.
            do{
                try item.managedObjectContext?.save()
            } catch {
                let saveError = error as NSError
                print("Unable to save item")
                print("\(saveError), \(saveError.localizedDescription)")
            }
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let categoryViewController = storyBoard.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryExpenseViewController
        categoryViewController.delegate = self
        navigationController?.pushViewController(categoryViewController, animated: true)
        
    }
    
    //MARK:- Alert
    func showAlert(msg:String){
        
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
            
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

}
extension AddExpenseViewController: CategoryViewDelegate
{
    
    func didSelect(category:String){
        
//        self.item?.category  = category
        self.categoryField.text = category
        
    }
}
