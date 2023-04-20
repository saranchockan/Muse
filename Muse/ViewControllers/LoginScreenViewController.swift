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
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email.layer.cornerRadius = 30
        let emailPaddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 23, height: 31))
        email.leftView = emailPaddingView
        email.leftViewMode = .always
        
        password.isSecureTextEntry = true
        password.layer.cornerRadius = 30
        let passPaddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 23, height: 31))
        password.leftView = passPaddingView
        password.leftViewMode = .always
        
        loginButton.layer.cornerRadius = 30
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func loginUser(_ sender: Any) {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) {authResult, error in
            if let error = error as NSError? {
              print("\(error.localizedDescription)")
                self.errorLabel.isHidden = false
                self.errorLabel.text = error.localizedDescription
            } else {
                print("User logged in... \(self.email.text!)")
                // Reset login fields
                self.email.text = ""
                self.password.text = ""
                
                var tabVC = self.storyboard?.instantiateViewController(withIdentifier: "TabControllerIdentifier") as! UITabBarController
                self.present(tabVC, animated: true)
                
            }
        }
        
    }
}
