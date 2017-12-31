//
//  AuthenticateViewController.swift
//  CoinTradeAlerts
//
//  Created by Harrison Leggio on 12/22/17.
//  Copyright © 2017 Harrison Leggio. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper

class AuthenticateViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var apiTextField: UITextField!
    @IBOutlet weak var secretTextField: UITextField!
    @IBOutlet weak var passphraseTextField: UITextField!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiTextField.delegate = self
        self.secretTextField.delegate = self
        self.passphraseTextField.delegate = self
        
        let foo: String? = KeychainWrapper.standard.string(forKey: "username")
        print(foo)

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
        apiTextField.resignFirstResponder()
        secretTextField.resignFirstResponder()
        passphraseTextField.resignFirstResponder()
        return (true)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: "username")
        
        let loginPage = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = loginPage
    }
    
    
    @IBAction func continueButton(_ sender: Any) {
        let apiKey = apiTextField.text!
        let secret = secretTextField.text!
        let passphrase = passphraseTextField.text!
        
        let username: String? = KeychainWrapper.standard.string(forKey: "username")
        
        
        if (apiKey.isEmpty) ||
            (secret.isEmpty) ||
            (passphrase.isEmpty) {
            self.displayMessage(userMessage: "All fields are required!")
        }
        
        let params: [String: Any] = [
            "api_key": apiKey,
            "secret_key": secret,
            "passphrase": passphrase,
            "username": username
        ]
        
        let postUrl = "/authenticate"
        var request = URLRequest(url: URL(string:postUrl)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params)
        
        Alamofire.request(request).responseJSON() { (response) in
            if let dictionary = response.result.value as? [String: Any] {
                let status = dictionary["status"]! as! Int
                if (status == 0){
                    print("Success")
                    
                    DispatchQueue.main.async {
                        let contactPage =
                            self.storyboard?.instantiateViewController(withIdentifier:
                                "ContactViewController") as! UIViewController
                        self.present(contactPage, animated: true, completion: nil)
                    }
                    
                }
                else {
                    print("Fail")
                    self.displayMessage(userMessage: "Something went wrong, please check the credentials you've entered!")
                    return
                    
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
