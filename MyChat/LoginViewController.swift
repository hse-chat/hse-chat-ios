//
//  ViewController.swift
//  MyChat
//
//  Created by Алексей on 14.06.16.
//  Copyright © 2016 Алексей. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet private weak var userNameField: UITextField!
    
    @IBOutlet private weak var passwordField: UITextField!

    @IBAction func loginTappedHandler(sender: AnyObject) {
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
                    let newReqBuilder = HseMsg.Request.Builder()
                    newReqBuilder.getSignUpBuilder().setPassword(password)
                    newReqBuilder.getSignUpBuilder().setUsername(username)
                    newReqBuilder.setId(1)
                    
                    do {
                        print("[LoginViewController]: Trying to sign up")
                        var request = try newReqBuilder.build()
                        ConnectionManager.sharedInstance.sendData(request)
                        
                    } catch {
                        print("[LoginViewController]: Sign up build failed")
                    }
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        
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

