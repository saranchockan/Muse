//
//  AddFriendsViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/2/23.
//

import UIKit
import FirebaseAuth

class AddFriendsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func finishRegistration(_ sender: Any) {
        newAccount = true
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
                "First Name": userFirstName,
                "Last Name": userLastName,
                "Phone Number": userPhoneNumber,
                "Location": userLocation,
                "Top Artists": [],
                "Top Songs": [String: String](),
                "friends": [],
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    
                    var tabVC = self.storyboard?.instantiateViewController(withIdentifier: "TabControllerIdentifier") as! UITabBarController
                    self.present(tabVC, animated: true)
                }
            }
        }
    }
}
