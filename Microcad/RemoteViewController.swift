//
//  RemoteViewController.swift
//  Microcad
//
//  Created by Pradeep Chandrasekaran on 10/01/19.
//  Copyright © 2019 Pradeep Chandrasekaran. All rights reserved.
//

import UIKit
import CoreBluetooth

class RemoteViewController: UIViewController,CBPeripheralDelegate, CBCentralManagerDelegate {
    
    
    @IBOutlet var powerButton: UIButton!
    @IBOutlet var hoursView1: UIView!
    @IBOutlet var hoursView2: UIView!
    @IBOutlet var speedView: UIView!
    @IBOutlet var typeView: UIView!
    @IBOutlet var button2H: UIButton!
    @IBOutlet var button4H: UIButton!
    @IBOutlet var button6H: UIButton!
    @IBOutlet var button8H: UIButton!
    @IBOutlet var buttonSpeed1: UIButton!
    @IBOutlet var buttonSpeed2: UIButton!
    @IBOutlet var buttonSpeed3: UIButton!
    @IBOutlet var buttonSpeed4: UIButton!
    @IBOutlet var buttonSpeed5: UIButton!
    @IBOutlet var buttonSpeed6: UIButton!
    @IBOutlet var buttonFan: UIButton!
    @IBOutlet var buttonREV: UIButton!
    @IBOutlet var buttonLED: UIButton!
    @IBOutlet var buttonSMT: UIButton!
    @IBOutlet var dataStringLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    var selectedPeripheral:CBPeripheral? = nil
    var centralManager:CBCentralManager? = nil
    var peripheralManager: CBPeripheralManager? = nil
    var txCharacteristic : CBCharacteristic?
    var rxCharacteristic : CBCharacteristic?
    var characteristicASCIIValue = NSString()
    var errorLabelString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hoursView1.layer.cornerRadius = 30
        hoursView2.layer.cornerRadius = 30
        speedView.layer.cornerRadius = 30
        typeView.layer.cornerRadius = 30
        roundedButton(passingView: hoursView1)
        roundedButton(passingView: hoursView2)
        roundedButton(passingView: speedView)
        roundedButton(passingView: typeView)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        selectedPeripheral?.delegate = self
        // print("Selected Peripheral : \(selectedPeripheral!)")
        selectedPeripheral?.discoverServices(nil)
        
        
    }
    
    func startOver() {
        let valueToSend = "R"
        let valueString = (valueToSend as NSString).data(using: String.Encoding.utf8.rawValue)
        if let blePeripheral = selectedPeripheral{
            if let txCharacteristic = txCharacteristic {
                
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
                
            }
        }
    }
    
    func roundedButton(passingView : UIView) {
        
        for view in passingView.subviews as [UIView] {
            
            if let button = view as? UIButton {
                button.layer.cornerRadius = button.frame.size.width / 2
                button.layer.borderWidth = 0.5
                button.layer.borderColor = UIColor.init(red: 154.0/255.0, green: 154.0/255.0, blue: 154.0/255.0, alpha: 0.40).cgColor
                button.layer.backgroundColor = UIColor.white.cgColor
                //button.layer.backgroundColor = UIColor.init(red: 91.0/255.0, green: 154.0/255.0, blue: 62.0/255.0, alpha: 1.0).cgColor
                
            }
        }
    }
    
    func enableDisableButtons(passingView : UIView, value : Bool) {
        
        for view in passingView.subviews as [UIView] {
            
            
            
            if let button = view as? UIButton {
                
                if(button == buttonLED) {
                    button.isEnabled = true
                }
                else {
                
                button.isEnabled = value
                }
                
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
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
                    startOver()
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
    
    func defaultButtonStyle() {
        buttonSpeed1.backgroundColor = UIColor.white
        buttonSpeed2.backgroundColor = UIColor.white
        buttonSpeed3.backgroundColor = UIColor.white
        buttonSpeed4.backgroundColor = UIColor.white
        buttonSpeed5.backgroundColor = UIColor.white
        buttonSpeed6.backgroundColor = UIColor.white
        buttonFan.backgroundColor = UIColor.white
        button2H.backgroundColor = UIColor.white
        button4H.backgroundColor = UIColor.white
        button6H.backgroundColor = UIColor.white
        button8H.backgroundColor = UIColor.white
        buttonREV.backgroundColor = UIColor.white
        buttonLED.backgroundColor = UIColor.white
        buttonSMT.backgroundColor = UIColor.white
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if characteristic == rxCharacteristic {
            
            //  print(characteristic.descriptors ?? 0)
            if let ASCIIString = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) {
                defaultButtonStyle()
                enableDisableButtons(passingView: hoursView1, value: true)
                enableDisableButtons(passingView: hoursView2, value: true)
                enableDisableButtons(passingView: typeView, value: true)
                
                print(ASCIIString)
                dataStringLabel.text = ASCIIString as String
                
                
                let onOffSpeed = ASCIIString.substring(with: NSRange(location: 1, length: 2)) //S
                let timer = ASCIIString.substring(with: NSRange(location: 3, length: 2)) //T
                let reverse = ASCIIString.substring(with: NSRange(location: 7, length: 2)) //R
                let led = ASCIIString.substring(with: NSRange(location: 9, length: 2)) //L
                let smart = ASCIIString.substring(with: NSRange(location: 5, length: 2)) //M
                let errorString = ASCIIString.substring(with: NSRange(location: 14, length: 3)) //I
                
                
                
                
                switch onOffSpeed {
                case "S0" : powerButton.setImage(UIImage(named: "PowerOff"), for: .normal)
                enableDisableButtons(passingView: hoursView1, value: false)
                enableDisableButtons(passingView: hoursView2, value: false)
                enableDisableButtons(passingView: typeView, value: false)
                    
                case "S1" : powerButton.setImage(UIImage(named: "PowerOn"), for: .normal)
                buttonSpeed1.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                    
                case "S2" : powerButton.setImage(UIImage(named: "PowerOn"), for: .normal)
                buttonSpeed2.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                    
                case "S3" : powerButton.setImage(UIImage(named: "PowerOn"), for: .normal)
                buttonSpeed3.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                    
                case "S4" : powerButton.setImage(UIImage(named: "PowerOn"), for: .normal)
                buttonSpeed4.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                    
                case "S5" : powerButton.setImage(UIImage(named: "PowerOn"), for: .normal)
                buttonSpeed5.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                    
                case "S6" : powerButton.setImage(UIImage(named: "PowerOn"), for: .normal)
                buttonSpeed6.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                case "S7" : powerButton.setImage(UIImage(named: "PowerOn"), for: .normal)
                buttonFan.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                    
                case "S8" : powerButton.setImage(UIImage(named: "PowerOn"), for: .normal)
               
                    //                case _ where ASCIIString.contains("T2") : powerButton.setImage(UIImage(named: "PowerOn"), for: .normal)
                    //                button2H.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                    //                case _ where ASCIIString.contains("T4") : powerButton.setImage(UIImage(named: "PowerOn"), for: .normal)
                    //                button4H.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                    //
                    //                case _ where ASCIIString.contains("T6") : powerButton.setImage(UIImage(named: "PowerOn"), for: .normal)
                    //                button6H.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                    //
                    //                case _ where ASCIIString.contains("T8") : powerButton.setImage(UIImage(named: "PowerOn"), for: .normal)
                    //                button8H.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                    
                default :
                    powerButton.setImage(UIImage(named: "PowerOff"), for: .normal)
                    
                    
                }
                
                switch timer {
                case "T2" : button2H.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                case "T4" : button4H.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                case "T6" : button6H.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                case "T8" : button8H.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                default :
                    button2H.backgroundColor = UIColor.white
                    button4H.backgroundColor = UIColor.white
                    button6H.backgroundColor = UIColor.white
                    button8H.backgroundColor = UIColor.white
                }
                
                switch reverse {
                case "R1" : buttonREV.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                    
                default :
                    buttonREV.backgroundColor = UIColor.white
                    
                }
                
                switch led {
                case "L1" : buttonLED.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                    
                default :
                    buttonLED.backgroundColor = UIColor.white
                    
                }
                
                switch smart {
                case "M1" : buttonSMT.backgroundColor = UIColor.init(red: 91.0/255.0, green: 166.0/255.0, blue: 62.0/255.0, alpha: 1.0)
                enableDisableButtons(passingView: speedView, value: false)
                    
                default :
                    buttonSMT.backgroundColor = UIColor.white
                    enableDisableButtons(passingView: speedView, value: true)
                    
                }
                
                switch errorString {
                    
                case "I20" :
                    errorLabel.text = "Over Current"
                case "I30" :
                    errorLabel.text = "Over Voltage"
                case "I50" :
                    errorLabel.text = "Motor Failure"
                case "I60" :
                    errorLabel.text = "Over Temperature"
                default :
                    errorLabel.text = ""
                    
                    
                }
                
                
                
                
            }
        }
    }
    
    @IBAction func powerButtonAction(_ sender: UIButton) {
        let valueToSend = "A"
        let valueString = (valueToSend as NSString).data(using: String.Encoding.utf8.rawValue)
        if let blePeripheral = selectedPeripheral{
            if let txCharacteristic = txCharacteristic {
                
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
                
            }
        }
    }
    
    @IBAction func twofourHoursButtonAction(_ sender: UIButton) {
        
        var valueToSend = ""
        switch (sender.tag) {
        case 1:
            valueToSend = "J"
        case 2:
            valueToSend = "K"
            
        default:
            valueToSend = ""
        }
        
        let valueString = (valueToSend as NSString).data(using: String.Encoding.utf8.rawValue)
        if let blePeripheral = selectedPeripheral{
            if let txCharacteristic = txCharacteristic {
                
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
                
            }
        }
        
        
    }
    
    @IBAction func sixeightHoursButtonAction(_ sender: UIButton) {
        
        
        var valueToSend = ""
        switch (sender.tag) {
        case 1:
            valueToSend = "O"
        case 2:
            valueToSend = "L"
            
        default:
            valueToSend = ""
        }
        
        let valueString = (valueToSend as NSString).data(using: String.Encoding.utf8.rawValue)
        if let blePeripheral = selectedPeripheral{
            if let txCharacteristic = txCharacteristic {
                
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
                
            }
        }
        
        
    }
    
    @IBAction func speedButtonAction(_ sender: UIButton) {
        var valueToSend = ""
        switch (sender.tag) {
        case 1:
            valueToSend = "C"
        case 2:
            valueToSend = "D"
        case 3:
            valueToSend = "E"
        case 4:
            valueToSend = "F"
        case 5:
            valueToSend = "G"
        case 6:
            valueToSend = "H"
        case 7:
            valueToSend = "I"
            
        default:
            valueToSend = ""
        }
        
        let valueString = (valueToSend as NSString).data(using: String.Encoding.utf8.rawValue)
        if let blePeripheral = selectedPeripheral{
            if let txCharacteristic = txCharacteristic {
                
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
                
            }
        }
    }
    
    
    @IBAction func fanTypeAction(_ sender: UIButton) {
        var valueToSend = ""
        switch (sender.tag) {
        case 1:
            valueToSend = "M"
        case 2:
            valueToSend = "B"
        case 3:
            valueToSend = "N"
            
        default:
            valueToSend = ""
        }
        
        let valueString = (valueToSend as NSString).data(using: String.Encoding.utf8.rawValue)
        if let blePeripheral = selectedPeripheral{
            if let txCharacteristic = txCharacteristic {
                
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
                
            }
        }
        
    }
    
    
    
}
