//
//  ScanViewController.swift
//  Microcad
//
//  Created by Pradeep Chandrasekaran on 03/01/19.
//  Copyright © 2019 Pradeep Chandrasekaran. All rights reserved.
//

import UIKit
import CoreBluetooth
import SVProgressHUD

class ScanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralManagerDelegate {

    var peripherals:[CBPeripheral] = []
    var centralManager:CBCentralManager? = nil
    var controllerView : ControllerViewController? = nil
    var selectedPeripheral:CBPeripheral? = nil
    var bleManager: BLEManager?
    var deviceScanningWork : DispatchWorkItem?
   

    
    @IBOutlet var stopScanButton: UIButton!
    @IBOutlet var pullToScanLabel: UILabel!
    @IBOutlet var peripheralTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
//        stopScanButton.isEnabled = false
     //   pullToScanLabel.isHidden = true
        peripheralTableView.delegate = self
        peripheralTableView.dataSource = self
        
        bleManager = BLEManager.sharedInstance
        centralManager = bleManager?.centralManager
        centralManager?.delegate = self
//        centralManager?.delegate = self

       
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
       // pullToScanLabel.isHidden = true
        
            peripherals.removeAll()
            scanBLEDevices()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopScanForBLEDevices()

    }
    
    
    func scanBLEDevices() {
        
//        stopScanButton.isEnabled = true
        //centralManager?.scanForPeripherals(withServices: [BLEService_UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
        
       bleManager?.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        
         deviceScanningWork = DispatchWorkItem(block: {
            self.stopScanForBLEDevices()
            self.peripheralTableView.reloadData()
        })
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0, execute: deviceScanningWork!)
        
    }
    
    func stopScanForBLEDevices() {
       deviceScanningWork?.cancel()
        centralManager?.stopScan()
        print("Scanning stopped")
        //pullToScanLabel.isHidden = false
        print(peripherals.count)
        
    }
    
   
    //MARK:- Central Manager Delegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print("Central manager state : \(central.state)")
    }
    
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("Peripheral manager State: \(peripheral.state)")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        
        print(device as Any)
        
        
        if(!peripherals.contains(peripheral)) {
            peripherals.append(peripheral)
        }
       // print(peripherals)
        self.peripheralTableView.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        stopScanForBLEDevices()
        print(peripheral)
        selectedPeripheral = peripheral
        peripheral.delegate = controllerView
       // peripheral.discoverServices(nil)
        SVProgressHUD.dismiss()
        performSegue(withIdentifier: "controlSegue", sender: self)
        
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        SVProgressHUD.showError(withStatus: "Device couldn't be paired : \(error?.localizedDescription). Searching for the device to pair")
        SVProgressHUD.dismiss(withDelay: 3)
        scanBLEDevices()
    }
    
    //MARK:- Seague
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "controlSegue") {
            let controlController : RemoteViewController = segue.destination as! RemoteViewController
           
           
            centralManager?.delegate = controlController


            controlController.centralManager = centralManager
            controlController.selectedPeripheral = selectedPeripheral
            
        }
    
        
    }
    
    
    // MARK:- Tableview Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "peripheralCell")
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell", for: indexPath)
        let peripheral = peripherals[indexPath.row]
       // let peripheralName = peripheral.name
        
        if peripheral.name == nil {
            cell.textLabel?.text = "N/A"
        }
        else {
        cell.textLabel?.text = peripheral.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let peripheral = peripherals[indexPath.row]
        centralManager?.connect(peripheral, options: nil)
        SVProgressHUD.show(withStatus: "Connecting...")
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        //cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.textColor = UIColor.init(red: 49.0/255.0, green: 122.0/255.0, blue: 206.0/255.0, alpha: 1.0)
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 18)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    //MARK:- Action Methods
   
    @IBAction func closeScanController(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stopScanning(_ sender: UIButton) {
        
        //pullToScanLabel.isHidden = false
    }
    

}
