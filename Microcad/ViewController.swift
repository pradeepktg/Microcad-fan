//
//  ViewController.swift
//  Microcad
//
//  Created by Pradeep Chandrasekaran on 28/12/18.
//  Copyright © 2018 Pradeep Chandrasekaran. All rights reserved.
//

import UIKit
import CoreBluetooth



class ViewController: UIViewController {
    
    // OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate
//    func didChange(_ state: OIDAuthState) {
//
//    }
//
//    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
//
//    }
    
//    var currentAuthorizationFlow: OIDAuthorizationFlowSession? = nil
//    let authorization: GTMAppAuthFetcherAuthorization? = nil
//    var authState:OIDAuthState? = nil
   
    
// let clientID = "101662916868-82uegj3k2g5ta5op5bep2lhqihusriq1.apps.googleusercontent.com"
// let kRedirectURI = URL(string: "com.googleusercontent.apps.101662916868-82uegj3k2g5ta5op5bep2lhqihusriq1:/oauthredirect")
    


    @IBOutlet var scanButton: UIButton!
    @IBOutlet var bluetoothStatusLabel: UILabel!
    
    var centralManager : CBCentralManager!
    let statusString = "Bluetooth Status :"
    var bleManager: BLEManager?
    var userName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationItem.hidesBackButton = true
        
        navigationController?.navigationBar.isHidden = false
        //CentralManagerShared.instance.centralManager = centralManager
       // centralManager = CBCentralManager(delegate: self, queue: nil)
        scanButton.layer.cornerRadius = scanButton.frame.size.width/2
        
        let nc = NotificationCenter.default
        
        nc.addObserver(forName: NSNotification.Name(rawValue: "UNSUPPORTED"), object: nil, queue: OperationQueue.main) { noti in
            
            self.bluetoothStatusLabel.text = ("\(self.statusString) UNSUPPORTED")
            
        }
        
        nc.addObserver(forName: NSNotification.Name(rawValue: "CONNECTIONNOTIFICATION"), object: nil, queue: OperationQueue.main) { noti in
            if let status = noti.userInfo?["CONNECTION"] as? Bool {
                
                if status == true {
                    self.bluetoothStatusLabel.text = ("\(self.statusString) ON")
                }
                if  status == false {
                    self.bluetoothStatusLabel.text = ("\(self.statusString) OFF")
                }
                

        
       
    }
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.navigationItem.hidesBackButton = true
    }

    override func viewDidAppear(_ animated: Bool) {
         self.navigationItem.hidesBackButton = true
        self.title = userName
        
        bleManager = BLEManager.sharedInstance
        centralManager = bleManager?.centralManager
    }

    override func viewDidDisappear(_ animated: Bool) {
//        centralManager = nil
//        bleManager = nil
    }
    
 // ******** Below delegate will be taken care by BLEManager class *********
            
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//
//        if central.state == CBManagerState.poweredOn {
//
//            bluetoothStatusLabel.text = ("\(statusString) ON")
//
//        }
//        else if central.state == CBManagerState.unsupported {
//
//             bluetoothStatusLabel.text = ("\(statusString) UNSUPPORTED")
//        }
//        else {
//            bluetoothStatusLabel.text = ("\(statusString) OFF")
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "scanSegue") {
            let scanController : ScanViewController = segue.destination as! ScanViewController

            //set the manager's delegate to the scan view so it can call relevant connection methods
            centralManager?.delegate = scanController
            scanController.centralManager = centralManager

        }

    }
    
    @IBAction func scanPeripherals(_ sender: Any) {
        
        if centralManager.state == CBManagerState.poweredOff {
            
            let alert = UIAlertController(title: "Bluetooth Status", message: "Looks like Bluetooth is disabled. Please enable from your phone settings", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else if  centralManager.state == CBManagerState.unsupported {
            
                let alert = UIAlertController(title: "Unsupported Device", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                    
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            
            
        }
        else {
            
            performSegue(withIdentifier: "scanSegue", sender: self)
        }
        
    }

}
