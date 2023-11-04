//
//  RegistrationViewController.swift
//  Microcad
//
//  Created by Pradeep Chandrasekaran on 29/01/19.
//  Copyright © 2019 Pradeep Chandrasekaran. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Alamofire
import SVProgressHUD
import SwiftyJSON


 let api = "f9eb90b2-2528-11e9-9ee8-0200cd936042"
var theUser = User()

class RegistrationViewController: UIViewController, UITextFieldDelegate  {
   
    
    
    
    @IBOutlet var lblPhoneNotification: UILabel!
    @IBOutlet var constraintMidY: NSLayoutConstraint!
    
    @IBOutlet var lblLocation: SkyFloatingLabelTextField!
    @IBOutlet var btnRegister: UIButton!
    @IBOutlet var lblName: SkyFloatingLabelTextField!
    
    @IBOutlet var lblPhone: SkyFloatingLabelTextField!
    @IBOutlet var lblEmail: SkyFloatingLabelTextField!
    var receivedVerification: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true

        
        
        lblName.delegate = self
        lblEmail.delegate = self
        lblPhone.delegate = self
        lblLocation.delegate = self
//        styleTextField(textField: lblName)
//        styleTextField(textField: lblEmail)
//        styleTextField(textField: lblPhone)
//        styleTextField(textField: lblLocation)
       // placeholder()
        
      
        
    }
    

//    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
//
//      controller.dismiss(animated: true, completion: nil)
//
//        }
//
    func showActionSheet(title: String, message: String) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

        actionSheet.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
           self.dismiss(animated: true, completion: nil)
        }))





        self.present(actionSheet, animated: true, completion: nil)

    }
    
    @IBAction func btnRegisterAction(_ sender: UIButton) {
 
        let name = lblName.text
        let email = lblEmail.text
        let phone = lblPhone.text
        let location = lblLocation.text
        
//        theUser.userName = name!
//        theUser.userEmail = email!
//        theUser.userPhone = phone!
//        theUser.userLocation = location!
//        performSegue(withIdentifier: "verificationSegue", sender: self)
//        return

        if(name!.isEmpty || email!.isEmpty || phone!.isEmpty || location!.isEmpty) {
            showActionSheet(title: "Mandatory", message: "All fields are mandatory")
        }
        else if(!isValidEmail(testStr: email!)) {

           showActionSheet(title: "Invalid", message: "Please enter a valid email id")

        }
        else if(phone!.count < 10) {
            
             showActionSheet(title: "Phone", message: "Please enter 10 digit phone number without any special character, country code or 0 prefix ")
        }

        else {
        SVProgressHUD.show(withStatus: "Creating account...")
        var fourDigitNumber: String {
            var result = ""
            repeat {
                // Create a string with a random number 0...9999
                result = String(format:"%04d", arc4random_uniform(10000) )
            } while result.count < 4
            return result
        }
        let autogenCode = fourDigitNumber

       let endPointURL = "https://2factor.in/API/V1/\(api)/SMS/\(phone!)/\(autogenCode)/fourdigitverification"


                Alamofire.request(endPointURL)
                    .responseJSON { response in

                    if response.result.isSuccess {
                        if let result = response.result.value {
                        let json = result as! [String: Any]
                        if let dataResult = json["Details"] {
                        //print(dataResult)
                        self.receivedVerification = dataResult as? String
                            theUser.userName = name!
                            theUser.userEmail = email!
                            theUser.userPhone = phone!
                            theUser.userLocation = location!
                        SVProgressHUD.dismiss()
                        self.performSegue(withIdentifier: "verificationSegue", sender:self)
                            }
                        }
                    }
                    else if response.result.isFailure {
                     SVProgressHUD.showError(withStatus: response.error?.localizedDescription)
                         SVProgressHUD.dismiss(withDelay: 3)

                      }

            }


        }

}

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "verificationSegue" {
            
            let verifyController : VerificationViewController = segue.destination as! VerificationViewController
            verifyController.receivedVerification = receivedVerification
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        self.view.endEditing(true)
    }
    
//    private func styleTextField(textField: UITextField)
//    {
//        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: textField.frame.height))
//        textField.leftView = leftPaddingView
//        textField.leftViewMode = .always
//
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        let nextTag = textField.tag + 1
        let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder?
        
        if nextResponder != nil {
            nextResponder?.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == lblLocation {
            UIView .animate(withDuration: 0.5) {
                self.constraintMidY.constant = -20
                self.view.layoutIfNeeded()
            }
        }
        if textField == lblPhone {
            lblPhoneNotification.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == lblLocation {
            UIView .animate(withDuration: 0.5) {
                self.constraintMidY.constant = 0
                 self.view.layoutIfNeeded()
            }
        }
        
        if textField == lblPhone {
            lblPhoneNotification.isHidden = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == lblPhone) {
           
            let maxLength = 10
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            
            
            let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
          
            let components = string.components(separatedBy: inverseSet)
          
            let filtered = components.joined(separator: "")
         
            return string == filtered && newString.length <= maxLength
        }
        return true
        
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
//    private func placeholder() {
//
//        lblName.attributedPlaceholder = NSAttributedString(string: "Enter Name", attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
//
//        lblEmail.attributedPlaceholder = NSAttributedString(string: "Enter Employee ID", attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
//
//        lblPhone.attributedPlaceholder = NSAttributedString(string: "Enter your Email ID", attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
//
//        lblLocation.attributedPlaceholder = NSAttributedString(string: "Set Password", attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
//
//    }
    
    
    
   
    
    
    }
