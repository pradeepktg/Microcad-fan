//
//  UUIDKey.swift
//  Microcad
//
//  Created by Pradeep Chandrasekaran on 03/01/19.
//  Copyright © 2019 Pradeep Chandrasekaran. All rights reserved.
//

import CoreBluetooth

import CoreBluetooth


let kBLEService_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
let kBLE_Characteristic_uuid_Tx = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
let kBLE_Characteristic_uuid_Rx = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"


let BLEService_UUID = CBUUID(string: kBLEService_UUID)
let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)
