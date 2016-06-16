//
//  ChunkedConnection.swift
//  HseChat
//
//  Created by Алексей on 16.06.16.
//  Copyright © 2016 Алексей. All rights reserved.
//

import Foundation
import Swocket

let SOCKET_HOST = "163.172.130.187"

let SOCKET_PORT : UInt = 8080

let PACKAGE_LENGTH : Int = 4

class ChunkedConnection {
    private var bufferLength : Int? = nil
    
    private var responseBuffer = NSMutableData()
    
    var isConnected : Bool = false
    
    let client = Swocket.TCP.init(host: SOCKET_HOST, port: SOCKET_PORT)
    
    func connect() {
        print("[ConnectionManager]: Trying to connect")
        do {
            try client.connect()
            self.isConnected = true
            self.setupReceiver()
        } catch {
            print("[ChunckedConnection] Error while connecting")
        }
    }
    
    func disconnect() {
        print ("[ChunckedConnection]: Disconnecting...")
        do {
            try client.disconnect()
        } catch {
            print("[ChunckedConnection] Error while disconnecting")
        }
        
    }
    
    func setupReceiver() {
        client.recieveDataAsync({ (data, error) -> Void in
            if let data = data {
                self.responseBuffer.appendData(data)
                self.receiveData()
                self.setupReceiver()
            } else if let error = error{
                print("[ChunckedConnection]: Error")
                self.disconnect()
            }
            
        })
    }
    
    func receiveData() {
        if self.bufferLength == nil && responseBuffer.length >= PACKAGE_LENGTH {
            let lengthData = self.responseBuffer.subdataWithRange(NSRange(location: 0, length: PACKAGE_LENGTH))
            var length = UInt32()
            
            lengthData.getBytes(&length, length: PACKAGE_LENGTH)
            self.bufferLength = Int(length.littleEndian)
            
            self.responseBuffer = NSMutableData(data: self.responseBuffer.subdataWithRange(NSRange(location: PACKAGE_LENGTH, length: self.responseBuffer.length - PACKAGE_LENGTH)))
            return self.receiveData()
        }
        
        if let bufferLength = self.bufferLength {
            if responseBuffer.length >= Int(bufferLength) {
                let package = self.responseBuffer.subdataWithRange(NSRange(location: 0, length: Int(bufferLength)))
                
                self.processPackage(package)
                
                self.bufferLength = nil
                
                self.responseBuffer = NSMutableData(data: self.responseBuffer.subdataWithRange(NSRange(location: bufferLength, length: self.responseBuffer.length - bufferLength)))
                self.receiveData()
            }
        }
    }
    
    func processPackage(package : NSData) {
        print("[ConnectionManager]: Received package")
        do {
            var serverMessage = try HseMsg.ServerMessage.parseFromData(package)
            var notificationName : String = ""
            if serverMessage.hasResult {
                notificationName.append(UnicodeScalar(serverMessage.result.id))
                NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: serverMessage.result)
            } else if serverMessage.hasEvent {
                if serverMessage.event.hasNewMessage {
                    NSNotificationCenter.defaultCenter().postNotificationName("newMessage", object: serverMessage.event.newMessage.message_)
                } else if serverMessage.event.hasNewUser {
                    NSNotificationCenter.defaultCenter().postNotificationName("newUser", object: serverMessage.event.newUser.user)
                }
            }
            
            
        } catch {
            print("[ConnectionManager]: Error parsing package")
            self.disconnect()
        }
    }
    
    func sendData(data: HseMsg.Request.Builder, id: UInt32) {
        do {
            data.setId(id)
            
            print("[ConnectionManager]: Building Package")
            var request = try data.build()
            
            print("[ConnectionManager]: Sending package")
            var req = NSMutableData()
            var hseReq = request.data()
            
            var length : Int = hseReq.length.littleEndian
            
            req.appendData(NSData(bytes: &length, length: 4))
            req.appendData(hseReq)
            
            do {
                // @TODO async
                try client.sendData(req)
            } catch {
                print("[ConnectionManager]: Error sending data")
            }
            
        } catch {
            print("[ConnectionManager]: Build failed")
        }
        
    }
}