//
//  DataManager.swift
//  HseChat
//
//  Created by Алексей on 15.06.16.
//  Copyright © 2016 Алексей. All rights reserved.
//

import Foundation

var REQUEST_ID : UInt32 = 0

struct RequestIdentificator {
    let id : UInt32
    let notificationName : String
}

class DataManager {
    
    static func getRequestIdentificator () -> RequestIdentificator {
        var notificationName : String = ""
        
        notificationName.append(UnicodeScalar(REQUEST_ID))
        
        let newId = RequestIdentificator(id: REQUEST_ID, notificationName: notificationName)
        
        REQUEST_ID += 1
        
        return newId
    }
    
    static func signUp(username: String, password: String, id: UInt32) {
        let newReqBuilder = HseMsg.Request.Builder()
        newReqBuilder.getSignUpBuilder().setPassword(password)
        newReqBuilder.getSignUpBuilder().setUsername(username)
        
        ConnectionManager.sharedInstance.sendData(newReqBuilder, id: id)
        
    }
    
    static func SignIn(username: String, password: String, id : UInt32) {
        let newReqBuilder = HseMsg.Request.Builder()
        newReqBuilder.getSignInBuilder().setPassword(password)
        newReqBuilder.getSignInBuilder().setUsername(username)
        
        ConnectionManager.sharedInstance.sendData(newReqBuilder, id: id)
    }
    
    static func sendMessage(content: String, username: String, id : UInt32) {
        let newReqBuilder = HseMsg.Request.Builder()
        newReqBuilder.getSendMessageToUserBuilder().setText(content).setReceiver(username)
        ConnectionManager.sharedInstance.sendData(newReqBuilder, id: id)
    }
    
    static func getMessagesWithUser(user: String, id : UInt32) {
        let newReqBulder = HseMsg.Request.Builder()
        newReqBulder.getGetMessagesWithUserBuilder().setWith(user)
        ConnectionManager.sharedInstance.sendData(newReqBulder, id: id)
    }
    
    static func getUsers(id: UInt32) {
        let newReqBulder = HseMsg.Request.Builder()
        newReqBulder.setGetUsers(HseMsg.Request.GetUsers())
        ConnectionManager.sharedInstance.sendData(newReqBulder, id: id)
    }
}