//
//  ConnectionManager.swift
//  MyChat
//
//  Created by Алексей on 14.06.16.
//  Copyright © 2016 Алексей. All rights reserved.
//

import Foundation
import Swocket

let SOCKET_HOST = "192.168.0.81"

let SOCKET_PORT : UInt = 80

class ConnectionManager : NSObject {
    static let sharedInstance = ConnectionManager()
    
    var lengthBuffer = NSMutableData()
    
    var responseBuffer = NSMutableData()
    
    var isConnected : Bool = false
    
    let client = Swocket.TCP.init(host: SOCKET_HOST, port: SOCKET_PORT)
    
    override init() {
        super.init()
    }
    
    func sendData(data: HseMsg.Request) {
        print("[ConnectionManager]: sending package")
        client.sendDataAsync(data.data())
    }
    
    func establishConnection() {
        client.connectAsync()
        print("[ConnectionManager]: connected to socket")
        
        client.recieveDataAsync({ (data, error) -> Void in
            if let data = data {
                print("Received data")
                if (self.lengthBuffer.length == 4) {
                    var length : UInt32 = 0
                    data.getBytes(&length, length: 4)
                    length = UInt32(littleEndian: length)
                    if self.responseBuffer.length == Int(length) {
                        print("Received package")
                        self.lengthBuffer = NSMutableData()
                        self.responseBuffer = NSMutableData()
                    } else {
                        self.responseBuffer.appendData(data)
                    }
                } else {
                    self.lengthBuffer.appendData(data)
                }
            }
        })
    }
    
    func disconnect() {
        client.disconnectAsync()
    }
    
}