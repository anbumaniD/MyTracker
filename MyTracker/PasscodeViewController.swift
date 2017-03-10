//
//  PasscodeViewController.swift
//  MyTracker
//
//  Created by Anbumani on 09/03/17.
//  Copyright © 2017 Anbu. All rights reserved.
//

import UIKit

class PasscodeViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
    @IBOutlet weak var passcodeField: UITextField!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (UserDefaults.standard.value(forKey: "PASSCODE") as? String) != nil {
            self.messageLabel.text = "Enter passcode to view your expenses"
        }else{
            self.messageLabel.text = "Set the passcode for your expense"
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
    }
    
    // MARK: - Button Actions
    @IBAction func doneAction(_ sender: AnyObject) {
        
        // Create UserDefaults
        let userDefaults = UserDefaults.standard
        let savedPasscode = userDefaults.value(forKey: "PASSCODE") as? String
        if let passcode = passcodeField.text{
            
            if savedPasscode == nil{
                userDefaults.set(passcode, forKey: "PASSCODE")
                dismiss(animated: false, completion: nil)
                self.showMyExpenses()
            }
            if passcode == savedPasscode{
                dismiss(animated: false, completion: nil)
                self.showMyExpenses()
                
            }else if passcode != savedPasscode{
                self.showAlert(msg: "Invalid passcode")
                return
            }
            
        }else{
            
            self.showAlert(msg: "Please enter passcode")
        }
        
    }
    
    //MARK:- Alert
    func showAlert(msg:String){
        
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
            
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK:- Present my expenses
    func showMyExpenses(){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let myExpensesViewController = storyBoard.instantiateViewController(withIdentifier: "MyExpensesViewController") as! ViewController
        navigationController?.viewControllers = [myExpensesViewController]
        
    }
    
    // MARK: - Text field delegate 
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return validateNumberField(textField: textField, range: range, string: string, charLength: 4)
    }
    
    //MARK:-  Text field validation
    func validateNumberField(textField: UITextField, range:NSRange, string:String,charLength:Int) -> Bool{
        
        if(string == ""){
            return true
        }
        let newLength = (textField.text?.characters.count)! + string.characters.count - range.length
        return newLength <= charLength
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
