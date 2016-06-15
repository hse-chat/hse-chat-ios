//
//  ContactsViewController.swift
//  MyChat
//
//  Created by Алексей on 14.06.16.
//  Copyright © 2016 Алексей. All rights reserved.
//

import Foundation
import UIKit

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    var filteredUsers = [String]()
    
    let users : [String] = ["Ray Wenderlich", "NSHipster", "iOS Developer Tips", "Jameson Quave", "Natasha The Robot", "Coding Explorer", "That Thing In Swift", "Andrew Bancroft", "iAchieved.it", "Airspeed Velocity"]
    
    let textCellIdentifier = "ContactCell"
    
    @IBOutlet var contactsTableView: UITableView!
    var resultSearchController = UISearchController()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 9.0, *) {
            self.resultSearchController.loadViewIfNeeded()// iOS 9
        } else {
            // Fallback on earlier versions
            let _ = self.resultSearchController.view          // iOS 8
        }
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.contactsTableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        self.contactsTableView.reloadData()
        
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func filterContentForSearchText(searchText: String) {
        self.filteredUsers = self.users.filter({( user: String) -> Bool in
            return user.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.active) {
            return self.filteredUsers.count
        }
        else {
            return self.users.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath)
        
        let row = indexPath.row
        
        if (self.resultSearchController.active) {
            cell.textLabel?.text = filteredUsers[row]
            
            return cell
        }
        else {
            cell.textLabel?.text = users[row]
            
            return cell
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filteredUsers.removeAll(keepCapacity: false)
        
        if let text = searchController.searchBar.text {
            let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", text)
            let array = (users as NSArray).filteredArrayUsingPredicate(searchPredicate)
            filteredUsers = array as! [String]
            
            self.contactsTableView.reloadData()
        }
        
        
    }
    
    
}

