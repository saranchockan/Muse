//
//  RegisterFirstViewController.swift
//  Muse
//
//  Created by Richa Gadre on 3/1/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class RegisterFirstViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email.layer.cornerRadius = 30
        let emailPaddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 23, height: 31))
        email.leftView = emailPaddingView
        email.leftViewMode = .always
        
        password.layer.cornerRadius = 30
        let passPaddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 23, height: 31))
        password.leftView = passPaddingView
        password.leftViewMode = .always
        
        confirmPassword.layer.cornerRadius = 30
        let confirmPaddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 23, height: 31))
        confirmPassword.leftView = confirmPaddingView
        confirmPassword.leftViewMode = .always
        
        continueButton.layer.cornerRadius = 30
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func continueToWelcomeScreen(_ sender: Any) {
        userEmail = email.text!
        userPassword = password.text!
//        let currentUser = Auth.auth().currentUser?.uid
//        let db = Database.database().reference()
        
//        let db = Firestore.firestore()
//        let ref = db.collection("Users")
//        var document = ref.document(currentUser!)
//
//        document.setData(["Email": userEmail])
    }

}
