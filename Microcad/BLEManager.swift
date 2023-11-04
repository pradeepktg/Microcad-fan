//
//  BLEManager.swift
//  Microcad
//
//  Created by Pradeep Chandrasekaran on 16/01/19.
//  Copyright © 2019 Pradeep Chandrasekaran. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc protocol BLEDelegate: class {
    
    func srgDiscoverServices(sender: BLEManager, peripheral: CBPeripheral)
    
}

class BLEManager: NSObject, CBCentralManagerDelegate {
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        let nc = NotificationCenter.default
        
        
        
        switch central.state {
        case .unsupported:
            nc.post(name: NSNotification.Name(rawValue: "UNSUPPORTED"), object: self, userInfo: nil)
            break
        case .unknown:
            nc.post(name: NSNotification.Name(rawValue: "UNKNOWN"), object: self, userInfo: nil)
        case .resetting:
           nc.post(name: NSNotification.Name(rawValue: "RESETTING"), object: self, userInfo: nil)
        case .unauthorized:
           nc.post(name: NSNotification.Name(rawValue: "UNAUTHORIZED"), object: self, userInfo: nil)
        case .poweredOff:
            print("Power off")
            
            nc.post(name: NSNotification.Name(rawValue: "CONNECTIONNOTIFICATION"), object: self, userInfo: ["CONNECTION" : false])
//            nc.post(name: NSNotification.Name(rawValue: "CONNECTIONNOTIFICATION"), object: self, userInfo: ["STATE" : self.connectedState, "CONNECTION" : false])
        case .poweredOn:
            print("Power On")
             nc.post(name: NSNotification.Name(rawValue: "CONNECTIONNOTIFICATION"), object: self, userInfo: ["CONNECTION" : true])
        }
    }
    
    var connectedState: Bool!
    static let connectionNotification = NSNotification.Name(rawValue: "CONNECTION_NOTIFICATION")
    static let sharedInstance = BLEManager()
    private static var initialised = false
    
     var centralManager : CBCentralManager!
    weak var delegate: BLEDelegate?
    
    let stringUUID = BLEService_UUID
    
    var bleDevices:[CBPeripheral] = []
    var bleCharacteristic = [String : CBCharacteristic]()
    
    override init() {
        assert(!BLEManager.initialised, "Illegal call to initializer - use sharedInstance")
        
        BLEManager.initialised = true
        
        super.init()
        
       // let centralQueue = dispatch_queue_create("com.stingray", dispatch_queue_serial_t)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    
    }
}
