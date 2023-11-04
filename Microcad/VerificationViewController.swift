//
//  VerificationViewController.swift
//  Microcad
//
//  Created by Pradeep Chandrasekaran on 30/01/19.
//  Copyright © 2019 Pradeep Chandrasekaran. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD





class VerificationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var verifyButton: UIButton!
    @IBOutlet var digit1: UITextField!
    @IBOutlet var digit2: UITextField!
    @IBOutlet var digit3: UITextField!
    @IBOutlet var digit4: UITextField!

    
    @IBOutlet var constraintHeightDigit1: NSLayoutConstraint!
    @IBOutlet var constraintHeightDigit2: NSLayoutConstraint!
    @IBOutlet var constraintHeightDigit3: NSLayoutConstraint!
    @IBOutlet var constraintHeightDigit4: NSLayoutConstraint!
    
    let kMailGunDomain = "sandbox106504132ac044c5bfc57c8fb9b2c036.mailgun.org"
    //sandbox462a15649166455dbb0d78595aff9343.mailgun.org
    let kMailGunAPI = "877d3fc830799f24c3bea5c42ebd02c7-4836d8f5-e8c12c42"
    //83dba243fd03d0fc617257b0dc41cf050-c8c889c9-19af3771
    
    var user = User()

    
    var receivedVerification : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

       navigationController?.navigationBar.isHidden = true
        
        digit1.delegate = self
        digit2.delegate = self
        digit3.delegate = self
        digit4.delegate = self

        digit1.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        digit2.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        digit3.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        digit4.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        digit1.becomeFirstResponder()
        verifyButton.isEnabled = false
         user = theUser
        print(user.userName)
 
    }
    
    override func viewDidLayoutSubviews() {
        let width = digit1.frame.size.width
        constraintHeightDigit1.constant = width
        constraintHeightDigit2.constant = width
        constraintHeightDigit3.constant = width
        constraintHeightDigit4.constant = width

    }
    
    @objc func textChanged(sender: UITextField) {
        
      
        if sender.text?.count == 1 {
            if sender.text?.first == " " {
                sender.text = ""
                return
            }
            else {
                let nextField = self.view.viewWithTag(sender.tag + 1) as? UITextField
                
                if nextField != nil {
                    nextField?.becomeFirstResponder()
                }
                else {
                    sender.resignFirstResponder()
                    
                }
            }
        }
        guard
            let one = digit1.text, !one.isEmpty,
            let two = digit2.text, !two.isEmpty,
            let three = digit3.text, !three.isEmpty,
            let four = digit4.text, !four.isEmpty
            else {
                verifyButton.isEnabled = false
                return
        }
        verifyButton.isEnabled = true
        
//           if sender.text?.count == 1  {
//             let nextField = self.view.viewWithTag(sender.tag + 1) as? UITextField
//
//            if nextField != nil {
//                 nextField?.becomeFirstResponder()
//            }
//            else {
//                sender.resignFirstResponder()
//
//            }
//
//
//        }
       
       
    }
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
      
        
        let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
        
        let components = string.components(separatedBy: inverseSet)
        
        let filtered = components.joined(separator: "")
        
            let maxLength = 1
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString

            return newString.length <= maxLength  && string == filtered

        
    }
    

    
    @IBAction func verifyOTP(_ sender: Any) {
        
        SVProgressHUD.show(withStatus: "Verifying...")
        let textFieldArray = [digit1,digit2,digit3,digit4]
        let enteredCode = textFieldArray.compactMap{$0?.text}.joined()
        let endPointURL =  "https://2factor.in/API/V1/\(api)/SMS/VERIFY/\(receivedVerification!)/\(enteredCode)"
        Alamofire.request(endPointURL)
                            .responseJSON { response in
        
                            if response.result.isSuccess {
                                if let result = response.result.value {
                                let json = result as! [String: Any]
                                if let dataResult = json["Details"] {
                                    
                                    let sucessString = dataResult as? String
                                    if sucessString?.lowercased().contains("matched") == true {
                                        let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.user)
                                        UserDefaults.standard.set(encodedData, forKey: "registeredUser")
                                        UserDefaults.standard.synchronize()
                                        self.sendMail()
                                        SVProgressHUD.showSuccess(withStatus: "Phone verified")
                                        SVProgressHUD.dismiss(withDelay: 3, completion: {
                                             self.performSegue(withIdentifier: "homeSegue", sender:self)
                                        })
                                    
                                       
                                        

                                    }
                                    
                                    if sucessString?.lowercased().contains("mismatch") == true {
                                        SVProgressHUD.showError(withStatus: "Invalid verification code. Please enter a valid code")
                                        SVProgressHUD.dismiss(withDelay:5)
                                        
                                    }

                                print(dataResult)
                               // self.receivedVerification = dataResult as? String
                                   
                                    }
                                }
                            }
                            else if response.result.isFailure {
                             SVProgressHUD.showError(withStatus: response.error?.localizedDescription)
                                SVProgressHUD.dismiss(withDelay: 3)
        
                              }
                    }
        

        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeSegue" {
            
            let homeController: ViewController = segue.destination as! ViewController
            homeController.userName = user.userName
        }
    }
    
    func sendMail() {
        
        let mailGun = Mailgun.client(withDomain:kMailGunDomain , apiKey:kMailGunAPI)
        mailGun?.sendMessage(to: "vivek2uall@gmail.com,cfappreceive@gmail.com", from: "cfappsend@gmail.com", subject: "New User Registered", body: "Hello, New user registered. \n Name : \(user.userName!) \n Email: \(user.userEmail!) \n Phone: \(user.userPhone!) \n Location: \(user.userLocation!) \n Date: \(Date()) \n Client: iOS App", success: { (data) in
            print(data as Any)
        }, failure: { (error) in
            print(error?.localizedDescription as Any)
        })
        
        
    }
    
}
