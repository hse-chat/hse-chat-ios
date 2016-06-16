//
//  MessagesViewController.swift
//  HseChat
//
//  Created by Алексей on 15.06.16.
//  Copyright © 2016 Алексей. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController

class MessagesViewController: JSQMessagesViewController {
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    var userName : String = ""
    
    var messages = [JSQMessage]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = userName
        
        let observer:NSObjectProtocol = NSNotificationCenter.defaultCenter().addObserverForName(
            "newMessage",
            object: nil, queue: nil,
            usingBlock: newMessageHandler)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var notificationId = DataManager.getRequestIdentificator()
        
        let observer:NSObjectProtocol = NSNotificationCenter.defaultCenter().addObserverForName(
            notificationId.notificationName,
            object: nil, queue: nil,
            usingBlock: getMessagesWithUserHandler)
        
        DataManager.getMessagesWithUser(userName, id: notificationId.id)
        
        self.setup()
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMessagesWithUserHandler(notification : NSNotification) {
        var messagesArray : [JSQMessage] = []
        if let result = notification.object as? HseMsg.Result {
            if result.hasGetMessagesWithUser {
                if let fetchedMessages = result.getMessagesWithUser {
                    fetchedMessages.messages.forEach({ (message) in
                        let newMessage = JSQMessage(senderId: message.author, senderDisplayName: message.author, date: NSDate(timeIntervalSince1970: NSTimeInterval(message.date)), text: message.text)
                        messagesArray.append(newMessage)
                    })
                    self.messages = messagesArray
                    self.reloadMessagesView()
                    self.scrollToBottomAnimated(false)
                }
            }
            NSNotificationCenter.defaultCenter().removeObserver(self, name: notification.name, object: nil)
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
    }
    
    
    func newMessageHandler(notification : NSNotification) {
        if let message = notification.object as? HseMsg.Message_ {
            if message.author == self.userName || message.receiver == self.userName {
                let newMessage = JSQMessage(senderId: message.author, senderDisplayName: message.author, date: NSDate(timeIntervalSince1970: NSTimeInterval(message.date)), text: message.text)
                self.messages.append(newMessage)
                self.reloadMessagesView()
                self.scrollToBottomAnimated(true)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "newMessage", object: nil)
    }
}

// TEST
extension MessagesViewController {
    
    func setup() {
        if let myUserName = ConnectionManager.sharedInstance.currentUser {
            self.senderId = myUserName
            self.senderDisplayName = myUserName
        }
        
    }
}

//MARK - Data Source
extension MessagesViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}

extension MessagesViewController {
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        var notificationId = DataManager.getRequestIdentificator()
        
        let observer:NSObjectProtocol = NSNotificationCenter.defaultCenter().addObserverForName(
            notificationId.notificationName,
            object: nil, queue: nil,
            usingBlock: sendMessageHandler)
        
        DataManager.sendMessage(text, username: userName, id: notificationId.id)
        self.finishSendingMessage()
        
    }
    
    func sendMessageHandler(notification: NSNotification) {
        if let result = notification.object as? HseMsg.Result {
            if result.hasSendMessageToUser {
                if Int(result.sendMessageToUser.status.rawValue) != 1 {
                    let alert = UIAlertController(title: "Message was not sent", message: result.sendMessageToUser.status.description , preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok" , style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated : true, completion: nil)
                }
            }
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name: notification.name, object: nil)
        }
        
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
}