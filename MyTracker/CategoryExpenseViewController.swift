//
//  CategoryExpenseViewController.swift
//  MyTracker
//
//  Created by Anbumani on 09/03/17.
//  Copyright © 2017 Anbu. All rights reserved.
//

import UIKit
protocol CategoryViewDelegate {
    
    func didSelect(category:String)
}

class CategoryExpenseViewController: UITableViewController {

    // MARK: - Properties
    
    let categories = ["Food","Fuel","Shopping","Electronics",
                      "Subscriptions","Billpay","Travel",
                      "Automobiles","Sports"]
    
    var delegate:CategoryViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Categories"
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = categories[indexPath.row]
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let delegate = delegate else {
            return
        }
        // Notify Delegate
        delegate.didSelect(category: categories[indexPath.row])
        
        // Dismiss View Controller
        _ = navigationController?.popViewController(animated: true)
        
    }
    
}
