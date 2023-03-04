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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func finishRegistration(_ sender: Any) {
        print(userFirstName)
        print(userLastName)
        print(userEmail)
        print(userPassword)
        print(userLocation)
        print(userPhoneNumber)
        // Register user with firebase Auth
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                print("Firebase auth error \(String(describing: error))")
                return
            }
            print("\(user.email!) created")
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
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }

        }
     
    }
}
