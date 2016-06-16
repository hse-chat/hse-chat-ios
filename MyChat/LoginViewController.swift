//
//  ViewController.swift
//  MyChat
//
//  Created by Алексей on 14.06.16.
//  Copyright © 2016 Алексей. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    private var tempUserName : String? = nil
    
    @IBOutlet private weak var userNameField: UITextField!
    
    @IBOutlet private weak var passwordField: UITextField!
    

    @IBAction func loginTappedHandler(sender: AnyObject) {
        if let username = self.userNameField.text {
            if let password = self.passwordField.text {
                    
                var notificationId = DataManager.getRequestIdentificator()
                
                let observer:NSObjectProtocol = NSNotificationCenter.defaultCenter().addObserverForName(
                    notificationId.notificationName,
                    object: nil, queue: nil,
                    usingBlock: signInHandler)
                
                self.tempUserName = username
                    
                DataManager.SignIn(username, password: password, id: notificationId.id)
            }
        }

    }
    
    @IBAction func registrationTappedHandler(sender: AnyObject) {
        if let username = self.userNameField.text {
            if let password = self.passwordField.text {
                if username.characters.count <= 4 {
                    let alert = UIAlertController(title: "Username should be more than 4 character count" , message: nil , preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok" , style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated : true, completion: nil)
                } else if password.characters.count <= 4 {
                    let alert = UIAlertController(title: "Password should be more than 4 character count" , message: nil , preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok" , style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated : true, completion: nil)
                } else {
                    
                    var notificationId = DataManager.getRequestIdentificator()

                    let observer:NSObjectProtocol = NSNotificationCenter.defaultCenter().addObserverForName(
                        notificationId.notificationName,
                        object: nil, queue: nil,
                        usingBlock: signUpHandler)
                    
                    self.tempUserName = username
                    
                    DataManager.signUp(username, password: password, id: notificationId.id)
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        
    }
    
    func signUpHandler(notification: NSNotification) {
        if let result = notification.object as? HseMsg.Result {
            if result.hasSignUp {
                if Int(result.signUp.status.rawValue) != 1 {
                    let alert = UIAlertController(title: result.signUp.status.description , message: nil , preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok" , style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated : true, completion: nil)
                } else {
                    ConnectionManager.sharedInstance.isSignedIn = true
                    ConnectionManager.sharedInstance.currentUser = self.tempUserName
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("MyNavigationController") as! UINavigationController
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func signInHandler(notification: NSNotification) {
        if let result = notification.object as? HseMsg.Result {
            if result.hasSignIn {
                if Int(result.signIn.status.rawValue) != 1 {
                    let alert = UIAlertController(title: result.signIn.status.description , message: nil , preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok" , style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated : true, completion: nil)
                } else {
                    ConnectionManager.sharedInstance.isSignedIn = true
                    ConnectionManager.sharedInstance.currentUser = self.tempUserName
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("MyNavigationController") as! UINavigationController
                    self.presentViewController(vc, animated: true, completion: nil)
                }
                NSNotificationCenter.defaultCenter().removeObserver(self, name: notification.name, object: nil)
            }
        }
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        userNameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

