//
//  LoginViewController.swift
//  CoinTradeAlerts
//
//  Created by Harrison Leggio on 12/22/17.
//  Copyright © 2017 Harrison Leggio. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self

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
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return (true)
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        
        if (username.isEmpty) || (password.isEmpty) {
            displayMessageAndDismiss(userMessage: "Both fields are required!")
            return
        }
        
        let params: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        let postUrl = "/login"
        
        var request = URLRequest(url: URL(string:postUrl)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params)
        
        Alamofire.request(request).responseJSON() { (response) in
            if let dictionary = response.result.value as? [String: Any] {
                print(dictionary)
                let status = dictionary["status"]! as! Int
                let username = dictionary["username"]! as! String
                print(username)
    
                if (status == 0){
                    
                    let saveUsername: Bool = KeychainWrapper.standard.set(username, forKey: "username")
                    print(saveUsername)
                    
                    
                    DispatchQueue.main.async {
                        let homePage =
                            self.storyboard?.instantiateViewController(withIdentifier:
                                "HomeViewController") as! UIViewController
                        self.present(homePage, animated: true)
                    }
                    
                }
                else {
                    print("Fail")
                    self.displayMessageAndDismiss(userMessage: "Incorrect username or password!")
                    return
                    
                }
            }
            
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
