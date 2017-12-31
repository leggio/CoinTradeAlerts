//
//  InfoViewController.swift
//  CoinTradeAlerts
//
//  Created by Harrison Leggio on 12/24/17.
//  Copyright © 2017 Harrison Leggio. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class InfoViewController: UIViewController {

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
    
    @IBAction func logoutButton(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: "username")
        
        let loginPage = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = loginPage
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
