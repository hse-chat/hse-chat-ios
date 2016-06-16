//
//  ConnectionManager.swift
//  MyChat
//
//  Created by Алексей on 14.06.16.
//  Copyright © 2016 Алексей. All rights reserved.
//

import Foundation
import Swocket
import ReachabilitySwift

class ConnectionManager {
    
    static let sharedInstance = ConnectionManager()
    
    var chunckedConnection = ChunkedConnection()
    
    var currentUser : String? = nil
    
    var isSignedIn : Bool = false
    
    func isConnected() -> Bool {
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
            return chunckedConnection.isConnected
        } catch {
            print("Unable to create Reachability")
            return false
        }

    }
    
    func sendData(data: HseMsg.Request.Builder, id: UInt32) {
        chunckedConnection.sendData(data, id: id)
    }
    
    
    func establishConnection() {
        chunckedConnection.connect()
    }
    
    func disconnect() {
        chunckedConnection.disconnect()
    }
    
}