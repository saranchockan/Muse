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
        
        // Register user with firebase Auth
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                print("Firebase auth error \(String(describing: error))")
                return
            }
            // Add user to Firebase user
            // collection: https://firebase.google.com/docs/firestore/manage-data/add-data#swift
            // Should only execute if firebase auth
            // is successful, get UID from auth response object
            db.collection("Users").document(user.uid).setData([
                "Email": userEmail,
                "First Name": "",
                "Last Name": "",
                "Phone Number": "",
                "Location": "",
                "Top Artists": [],
                "Top Songs": [String: String](),
                "friends": [],
                "requests": []
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    
                    let tabVC = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeScreen") as! WelcomeViewController
                    self.present(tabVC, animated: true)
                }
            }
        }
    }
    

}
