//
//  ProfileViewController.swift
//  CoinTradeAlerts
//
//  Created by Harrison Leggio on 12/23/17.
//  Copyright © 2017 Harrison Leggio. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func disableButton(_ sender: Any) {
        let username: String? = KeychainWrapper.standard.string(forKey: "username")
        
        let params: [String: Any] = [
            "username": username!
        ]
        
        let postUrl = "/disable"
        var request = URLRequest(url: URL(string:postUrl)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params)
        
        Alamofire.request(request).responseJSON() { (response) in
            if let dictionary = response.result.value as? [String: Any] {
                let status = dictionary["status"]! as! Int
                
                KeychainWrapper.standard.removeObject(forKey: "username")
                
                let loginPage = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = loginPage
                
            }
        }
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: "username")
        
        let loginPage = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = loginPage
    }
    
    

}
