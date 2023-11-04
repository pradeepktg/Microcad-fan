//
//  CentralManagerHandler.swift
//  Microcad
//
//  Created by Pradeep Chandrasekaran on 08/01/19.
//  Copyright © 2019 Pradeep Chandrasekaran. All rights reserved.
//

import Foundation
import CoreBluetooth


class CentralManagerShared: NSObject {
    
    
   
    
    static let instance = CentralManagerShared()
    static let connectionNotification = NSNotification.Name(rawValue: "CONNECTION_NOTIFICATION")
    
    fileprivate var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral!
    var connectedState: Bool!
    private let queue = DispatchQueue(label: "BTQueue")
    
    private override init() {
        
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: queue, options: [CBCentralManagerOptionRestoreIdentifierKey: " Central "])
    }
    
    func startScan() {
        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScan() {
        self.centralManager.stopScan()
    }
    
    func sendConnectionStatus() {
        
        let nc = NotificationCenter.default
        
        nc.post(name: CentralManagerShared.connectionNotification, object: self, userInfo: ["STATE" : self.connectedState, "CONNECTION" : true])
    }
    
    func sendDisconnectionNotification() {
        
        let nc = NotificationCenter.default
        nc.post(name: CentralManagerShared.connectionNotification, object: self, userInfo: ["STATE" : self.connectedState, "CONNECTION" : false])
    }
    
}


// MARK:- CentralManager Delegate

extension CentralManagerShared : CBCentralManagerDelegate {
   
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
       
        
    }
    
    
    
}
