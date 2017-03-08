//
//  AddExpenseViewController.swift
//  MyTracker
//
//  Created by Anbumani on 08/03/17.
//  Copyright © 2017 Anbu. All rights reserved.
//

import UIKit

protocol AddExpenseViewControllerDelegate {
    func controller(_ controller: AddExpenseViewController,
                    didAddExpense title: String, amount: Double, category: String, notes: String)
    
}

class AddExpenseViewController: UITableViewController {

    // MARK: - Properties
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var amountField: UITextField!
    
    @IBOutlet weak var categoryField: UITextField!
    
    @IBOutlet weak var notesField: UITextView!
    
    var delegate: AddExpenseViewControllerDelegate?
    
    var item: Expense?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Update the User Interface with expense item if availabel.
        
        if let item = item{
            
            nameField.text = item.title
            amountField.text = String(item.amount)
            categoryField.text = item.category
            notesField.text = item.notes
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        guard let title = nameField.text else {
            return
        }
        guard let amount = amountField.text else {
            return
        }
        guard let category = categoryField.text else {
            return
        }
        guard let notes = notesField.text else {
            return
        }

        guard let delegate = delegate else {
            return
        }
        
        // Notify Delegate
      
        delegate.controller(self, didAddExpense: title, amount: Double(amount)!, category: category, notes: notes)
        
        // Dismiss View Controller
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Dismiss View Controller
        dismiss(animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

}
