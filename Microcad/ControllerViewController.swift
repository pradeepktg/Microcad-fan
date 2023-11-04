//
//  ControllerViewController.swift
//  Microcad
//
//  Created by Pradeep Chandrasekaran on 04/01/19.
//  Copyright © 2019 Pradeep Chandrasekaran. All rights reserved.
//

import UIKit
import CoreBluetooth



class ControllerViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {

    @IBOutlet var button1: UIButton!
    @IBOutlet var speedControlsView: UIView!
    @IBOutlet var bluetoothStatusLabel: UILabel!
    @IBOutlet var powerLabel: UILabel!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var powerSegmentControl: UISegmentedControl!
    @IBOutlet var receivedValueLabel: UILabel!
    
    var selectedPeripheral:CBPeripheral? = nil
    var centralManager:CBCentralManager? = nil
    var peripheralManager: CBPeripheralManager? = nil
    var txCharacteristic : CBCharacteristic?
    var rxCharacteristic : CBCharacteristic?
    var characteristicASCIIValue = NSString()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

       

       
    }
    
    override func viewDidAppear(_ animated: Bool) {
     
         selectedPeripheral?.delegate = self
        print("Selected Peripheral : \(selectedPeripheral!)")
        selectedPeripheral?.discoverServices(nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
      
    }

    func roundedButton() {
        for view in self.speedControlsView.subviews as [UIView] {
           
            if let button = view as? UIButton {
                button.layer.cornerRadius = button.frame.size.width / 2
                
            }
        }
        
    }
    
    // MARK: CBPeripheralDelegate Methods
    //TODO: Use notification for the status change
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        var statusString = ""

        if central.state == CBManagerState.poweredOn {

           statusString = "ON"
        }
        if central.state == CBManagerState.poweredOff {
            statusString = "OFF"
        }
        bluetoothStatusLabel.text = "Bluetooth Status : \(statusString)"
    }

    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        //We need to discover the all characteristic
        for service in services {
            
            peripheral.discoverCharacteristics(nil, for: service)
        }
        print("Discovered Services: \(services)")
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                // Tx:
                if characteristic.uuid == BLE_Characteristic_uuid_Tx {
                    print("Tx char found: \(characteristic.uuid)")
                    txCharacteristic = characteristic
                    peripheral.setNotifyValue(true, for: txCharacteristic!)
                }
                
                // Rx:
                if characteristic.uuid == BLE_Characteristic_uuid_Rx {
                    rxCharacteristic = characteristic
                    if let rxCharacteristic = rxCharacteristic {
                        print("Rx char found: \(characteristic.uuid)")
                        peripheral.setNotifyValue(true, for: rxCharacteristic)
                    }
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        
//        let alertController = UIAlertController(title: "Connection Status", message: "Paired to \(String(describing: selectedPeripheral?.name))", preferredStyle: .alert)
//        
//        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
//            
//            self.dismiss(animated: true, completion: nil)
//        }
//        
//        alertController.addAction(action)
//        self.present(alertController, animated: true, completion: nil)
//        
//    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        selectedPeripheral = nil
        
        
        let alertController = UIAlertController(title: "Connection Status", message: "Unfortunately, paired service is disconnected. Please pair the device again", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
        
        
       
       
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if characteristic == rxCharacteristic {
           // print(characteristic)
            if let ASCIIString = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) {
                receivedValueLabel.text = "Received Value : \(ASCIIString)"
                print(ASCIIString)
                
            }
        }
    }
    
  
    
    @IBAction func speedButtonAction(_ sender: UIButton) {
        let valueToSend = String(sender.tag)
        let valueString = (valueToSend as NSString).data(using: String.Encoding.utf8.rawValue)
        if let blePeripheral = selectedPeripheral{
            if let txCharacteristic = txCharacteristic {
                speedLabel.text =  "Speed : \(valueToSend)"
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
                
            }
        }
    }
    
    @IBAction func powerAction(_ sender: UISegmentedControl) {
        
        var powerStatus = ""
        if sender.selectedSegmentIndex == 0 {
            powerStatus = "ON"
        }
        if sender.selectedSegmentIndex == 1 {
            powerStatus = "OFF"
        }
        powerLabel.text = "Power : \(powerStatus)"
    }
    

    
}
