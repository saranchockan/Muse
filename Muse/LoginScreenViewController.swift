//
//  LoginScreenViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 2/28/23.
//

import UIKit
import FirebaseAuth

class LoginScreenViewController: UIViewController {
    
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func loginUser(_ sender: Any) {
        print(email.text!)
        print(password.text!)
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { [weak self] authResult, error in
          print(authResult)
          print(error)
          return
        }
    }
    
}
