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
    
    var users : [String] = []
    
    let textCellIdentifier = "ContactCell"
    
    
    @IBOutlet var contactsTableView: UITableView!
    var resultSearchController = UISearchController()
    
    @IBOutlet weak var logoutButtonHandler: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let observer:NSObjectProtocol = NSNotificationCenter.defaultCenter().addObserverForName(
            "newUser",
            object: nil, queue: nil,
            usingBlock: newUserHandler)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        var requestId = DataManager.getRequestIdentificator()
        
        
        let observer:NSObjectProtocol = NSNotificationCenter.defaultCenter().addObserverForName(
            requestId.notificationName,
            object: nil, queue: nil,
            usingBlock: getUsersHandler)
        
        DataManager.getUsers(requestId.id)
        
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue,
                                  sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "selectContact" {
            if let destination = segue.destinationViewController as? MessagesViewController,
                userIndex = contactsTableView.indexPathForSelectedRow?.row {
                destination.userName = self.resultSearchController.active ? filteredUsers[userIndex] : users[userIndex]
            }
            
            
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
    
    func getUsersHandler(notification : NSNotification) {
        var usersArray : [String] = []
        if let result = notification.object as? HseMsg.Result {
            if result.hasGetUsers {
                if let fetchedUsers = result.getUsers {
                    fetchedUsers.users.forEach({ (user) in
                        usersArray.append(user.username)
                    })
                    self.users = usersArray
                    self.contactsTableView.reloadData()
                }
            }
           NSNotificationCenter.defaultCenter().removeObserver(self, name: notification.name, object: nil)
        }
    }
    
    func newUserHandler(notification : NSNotification) {
        if let newUser = notification.object as? HseMsg.User {
            self.users.append(newUser.username)
            self.contactsTableView.reloadData()
        }
    }
    
    
}

