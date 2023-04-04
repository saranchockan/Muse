//
//  MyFriendsViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/2/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class MyFriendsViewController: UIViewController {
    
    var currentUserObject:User = User()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getFriends { completion in
            if completion {
                print("MY FRIENDS: \(self.currentUserObject.friends.count)")
            } else {
                print("error")
            }
        }
    }
    
    func getFriends(_ completion: @escaping (_ success: Bool) -> Void) {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let ref = db.collection("Users")
        
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    if document.documentID == currentUser {
                        self.currentUserObject.uid = currentUser!
                        
                        let data = document.data()
                        let friends = data["friends"] as! [String]
                        
                        for friend in friends {
                            ref.whereField(FieldPath.documentID(), isEqualTo: friend).getDocuments()
                            {(querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    print("In friend loop")
                                    for document in querySnapshot!.documents {
                                        let friendName: String = "\(document.data()["First Name"]!) \(document.data()["Last Name"]!) "
                                        self.currentUserObject.friends.append(friendName)
                                    }
                                    
                                    completion (true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
