//
//  RegisterViewController.swift
//  CoinTradeAlerts
//
//  Created by Harrison Leggio on 12/22/17.
//  Copyright © 2017 Harrison Leggio. All rights reserved.
//

import UIKit
import Alamofire

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.repeatPasswordTextField.delegate = self
        self.emailTextField.delegate = self
        
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        repeatPasswordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        return (true)
    }
   
    @IBAction func registerButton(_ sender: Any) {
        if (usernameTextField.text?.isEmpty)! ||
            (emailTextField.text?.isEmpty)! ||
            (passwordTextField.text?.isEmpty)! ||
            (repeatPasswordTextField.text?.isEmpty)!
        {
            displayMessage(userMessage: "All fields are required!")
            return
        }
        
        if (passwordTextField.text!.count < 8) {
            displayMessage(userMessage: "Password must be at least 8 characters!")
            return
        }
        
        if (usernameTextField.text!.count < 6) {
            displayMessage(userMessage: "Username must be at least 6 characters!")
        }
        
        if ((passwordTextField.text! == repeatPasswordTextField.text!) != true) {
            displayMessage(userMessage: "Passwords do not match!")
        }
        
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        let email = emailTextField.text!
        
        let params: [String: Any] = [
            "username": username,
            "password": password,
            "email": email
        ]
        
        let postUrl = "/register"
        var request = URLRequest(url: URL(string:postUrl)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params)
        
        Alamofire.request(request).responseJSON() { (response) in
            if let dictionary = response.result.value as? [String: Any] {
                let username = dictionary["username"]!
                let status = dictionary["status"]! as! Int
                let message = dictionary["message"]
                
                if (status == 0){
                    print("Success")
                    self.displayMessageAndDismiss(userMessage: "Got it! We've created your account!")
                }
                else {
                    print("Fail")
                    self.displayMessage(userMessage: message as! String)
                    
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
