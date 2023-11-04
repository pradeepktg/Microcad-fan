//
//  CheckerViewController.swift
//  Microcad
//
//  Created by Pradeep Chandrasekaran on 01/02/19.
//  Copyright © 2019 Pradeep Chandrasekaran. All rights reserved.
//

import UIKit
import SVProgressHUD

class CheckerViewController: UIViewController {
    
    var userName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
        
       
        checkforRegisteredUser()
    }
    
    
    
    func checkforRegisteredUser() {
        if let data = UserDefaults.standard.object(forKey: "registeredUser") as? Data {
            if let user = NSKeyedUnarchiver.unarchiveObject(with: data) as? User {
              
                    userName = user.userName
                    self.performSegue(withIdentifier: "directHomeSegue", sender: self)
        
            }
        }
        else {
            performSegue(withIdentifier: "registerationSegue", sender: self)
        }
        SVProgressHUD.dismiss()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "directHomeSegue" {
           let homeController : ViewController = segue.destination as! ViewController
            homeController.userName = userName
        }
    }


}
