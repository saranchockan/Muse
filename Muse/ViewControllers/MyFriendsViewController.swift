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

class MyFriendsViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    var currentUserObject:User = User()

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var friends: [String] = ["Saahithi", "Liz"]
    var requests: [String] = ["Richa", "Saran"]
    var tableData: [String] = []
    let cellIdentifier = "FriendCard"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "FriendCard", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableData = friends

        self.getFriends { completion in
            if completion {
                print("MY FRIENDS: \(self.currentUserObject.friends.count)")
            } else {
                print("error")
            }
        }
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            tableData = friends
            tableView.reloadData()
        case 1:
            tableData = requests
            tableView.reloadData()
        default:
            print("this isn't supposed to happen")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendCardTableViewCell
        cell.name.text = tableData[indexPath.row]
        if (segmentControl.selectedSegmentIndex == 0) {
            cell.button.setTitle("Remove", for: .normal)
        } else {
            cell.button.setTitle("Add", for: .normal)
        }
        return cell
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
