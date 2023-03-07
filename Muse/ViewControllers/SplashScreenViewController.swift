//
//  ViewController.swift
//  Muse
//
//  Created by Saahithi Joopelli on 2/28/23.
//

import UIKit

class SplashScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginScreenIdentifier") as! LoginScreenViewController
            self.present(nextVC, animated: true)
        }
    }
}

