//
//  ContactViewController.swift
//  CoinTradeAlerts
//
//  Created by Harrison Leggio on 12/23/17.
//  Copyright © 2017 Harrison Leggio. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper

class ContactViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var contactField: UITextField!
    @IBOutlet weak var carrierDropDown: DropMenuButton!
    var carrier = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contactField.delegate = self
        
        carrierDropDown.initMenu(["AT&T", "Verizon", "T-Mobile", "Sprint", "Boost Mobile", "Cricket Wireless"],
                                actions: [({ () -> (Void) in self.carrier = "@txt.att.net" }),
                                          ({ () -> (Void) in self.carrier = "@vtext.com" }),
                                          ({ () -> (Void) in self.carrier = "@tmomail.net" }),
                                          ({ () -> (Void) in self.carrier = "@@messaging.sprintpcs.com" }),
                                          ({ () -> (Void) in self.carrier = "@myboostmobile.com" }),
                                          ({ () -> (Void) in self.carrier = "@mms.cricketwireless.net" })])

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contactField.resignFirstResponder()
        return (true)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: "username")
        
        let loginPage = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = loginPage
    }
    
    @IBAction func finishButton(_ sender: Any) {
        let number = contactField.text!
        
        if (number.isEmpty) {
            self.displayMessage(userMessage: "All fields are required!")
        }
        
        let contact = number + carrier
        let username: String? = KeychainWrapper.standard.string(forKey: "username")
        
        let params: [String: Any] = [
            "contact": contact,
            "username": username!
        ]
        
        let postUrl = "/contact"
        var request = URLRequest(url: URL(string:postUrl)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params)
        
        Alamofire.request(request).responseJSON() { (response) in
            if let dictionary = response.result.value as? [String: Any] {
                let status = dictionary["status"]! as! Int
                
                DispatchQueue.main.async {
                    let profilePage =
                        self.storyboard?.instantiateViewController(withIdentifier:
                            "ProfileViewController") as! UIViewController
                    self.present(profilePage, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async
            {
                
                let alertController = UIAlertController(title: "Alert", message:
                    userMessage, preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default)
                {
                    (action:UIAlertAction!) in
                    print("Ok button tapped")
                    //DispatchQueue.main.async
                    //    {
                    //  self.dismiss(animated: true, completion: nil)
                    //}
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func displayMessageAndDismiss(userMessage:String) -> Void {
        DispatchQueue.main.async
            {
                
                let alertController = UIAlertController(title: "Alert", message:
                    userMessage, preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default)
                {
                    (action:UIAlertAction!) in
                    print("Ok button tapped")
                    DispatchQueue.main.async
                        {
                            self.dismiss(animated: true, completion: nil)
                    }
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
        }
    }
}
