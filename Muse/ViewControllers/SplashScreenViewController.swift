//
//  ViewController.swift
//  Muse
//
//  Created by Saahithi Joopelli on 2/28/23.
//

import UIKit
import FirebaseAuth

var newAccount = false

class SplashScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            Auth.auth().addStateDidChangeListener() {
                auth, user in
                var nextVC =  UIViewController()
                if user != nil {
                    nextVC = self.storyboard?.instantiateViewController(withIdentifier: "TabControllerIdentifier") as! UITabBarController
                } else {
                    nextVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginScreenIdentifier") as! LoginScreenViewController
                    
                }
                self.present(nextVC, animated: true)
            }
            
        }
        
        
    }
}

