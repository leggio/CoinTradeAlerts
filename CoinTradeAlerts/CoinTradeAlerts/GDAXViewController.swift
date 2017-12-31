//
//  GDAXViewController.swift
//  CoinTradeAlerts
//
//  Created by Harrison Leggio on 12/22/17.
//  Copyright © 2017 Harrison Leggio. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class GDAXViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let username: String? = KeychainWrapper.standard.string(forKey: "username")
        print(username)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func gdaxButton(_ sender: Any) {
        let gdaxURL = NSURL(string: "https://www.gdax.com/settings/api")! as URL
        UIApplication.shared.open(gdaxURL, options: [:], completionHandler: nil)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: "username")
        
        let loginPage = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = loginPage
    }
    
    
}

