//
//  ContactsViewController.swift
//  MyChat
//
//  Created by Алексей on 14.06.16.
//  Copyright © 2016 Алексей. All rights reserved.
//

import Foundation
import UIKit

struct ContactsUser {
    var username : String
    var isOnline : Bool
}

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    var filteredUsers = [String]()
    
    var usersContacts : [ContactsUser] = [] {
        didSet {
            var newUsers : [String] = []
            usersContacts.forEach({ (user) -> Void in
                if user.isOnline && onlineControl.selectedSegmentIndex == 0 {
                    newUsers.append(user.username)
                } else if !user.isOnline && onlineControl.selectedSegmentIndex == 1 {
                    newUsers.append(user.username)
                }
            })
            self.users = newUsers
            self.contactsTableView.reloadData()
        }
    }
    
    var users : [String] = []
    
    let textCellIdentifier = "ContactCell"
    
    
    @IBOutlet var contactsTableView: UITableView!
    var resultSearchController = UISearchController()
    
    @IBOutlet weak var onlineControl: UISegmentedControl!
    
    @IBAction func onlineButtonHandler(sender: AnyObject) {
        var newUsers : [String] = []
        usersContacts.forEach({ (user) -> Void in
            if user.isOnline && onlineControl.selectedSegmentIndex == 0 {
                newUsers.append(user.username)
            } else if !user.isOnline && onlineControl.selectedSegmentIndex == 1 {
                newUsers.append(user.username)
            }
        })
        self.users = newUsers
        self.contactsTableView.reloadData()
    }
    
    
    @IBAction func logoutButtonHandler(sender: UIButton) {
        let alert = UIAlertController(title: "Do you really want to log out", message: nil , preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel" , style: UIAlertActionStyle.Cancel, handler: nil))
        let logoutAction = UIAlertAction(title: "Log Out", style: .Destructive) { (action) in
            ConnectionManager.sharedInstance.disconnect()
            let loginPageView = self.storyboard?.instantiateViewControllerWithIdentifier("LoginPage") as! LoginViewController
            self.navigationController?.presentViewController(loginPageView, animated: true, completion: nil)
        }
        alert.addAction(logoutAction)
        self.presentViewController(alert, animated : true, completion: nil)
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let observer:NSObjectProtocol = NSNotificationCenter.defaultCenter().addObserverForName(
            "newUser",
            object: nil, queue: nil,
            usingBlock: newUserHandler)
        
        let updateObserver:NSObjectProtocol = NSNotificationCenter.defaultCenter().addObserverForName(
            "userUpdated",
            object: nil, queue: nil,
            usingBlock: userUpdatedHanler)
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
        var usersArray : [ContactsUser] = []
        if let result = notification.object as? HseMsg.Result {
            if result.hasGetUsers {
                if let fetchedUsers = result.getUsers {
                    fetchedUsers.users.forEach({ (user) in
                        usersArray.append(ContactsUser(username: user.username, isOnline: user.online))
                    })
                    self.usersContacts = usersArray
                }
            }
           NSNotificationCenter.defaultCenter().removeObserver(self, name: notification.name, object: nil)
        }
    }
    
    func newUserHandler(notification : NSNotification) {
        if let newUser = notification.object as? HseMsg.User {
            self.usersContacts.append(ContactsUser(username: newUser.username, isOnline: newUser.online))
        }
    }
    
    func userUpdatedHanler(notification : NSNotification) {
        if let newUser = notification.object as? HseMsg.User {
            var newUsers : [ContactsUser] = []
            for var user in usersContacts {
                if user.username == newUser.username {
                    user.isOnline = newUser.online
                }
                newUsers.append(user)
                
            }
            self.usersContacts = newUsers
        }
    }
    
    
}

