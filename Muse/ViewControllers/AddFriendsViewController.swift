//
//  AddFriendsViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/2/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class AddFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ModifyFriendsDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    let cellIdentifier = "FriendCard"
    var currentUserObject: User!
    var potentialFriends: [User] = []
    var filteredPotentialFriends: [User] = []
    var selectedSet: Set<FriendCardTableViewCell> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.register(UINib.init(nibName: "FriendCard", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        self.getNonFriendUsers { completion in
            if completion {
                print ("potential friends in completion size", self.potentialFriends.count)
                self.filteredPotentialFriends = self.potentialFriends
                self.tableView.reloadData()
            } else {
                print("error getting potential user objects")
            }
        }
    }
    
    func addSelectedToSet(cell: FriendCardTableViewCell) {
        selectedSet.insert(cell)
    }
    
    func removeSelectedFromSet(cell: FriendCardTableViewCell) {
        selectedSet.remove(cell)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPotentialFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendCardTableViewCell
        cell.name.text = "\(filteredPotentialFriends[indexPath.row].firstName) \(filteredPotentialFriends[indexPath.row].lastName)"
        cell.currentUserObject = currentUserObject
        cell.friendObject = filteredPotentialFriends[indexPath.row]
        cell.delegate = self
        cell.button.isSelected = false
        cell.button.backgroundColor = UIColor(red: 31/255, green: 34/255, blue: 42/255, alpha: 1)
        cell.button.setTitle("Request", for: .normal)
        cell.button.setTitle("Requested", for: .selected)
        return cell
    }
    
    func getNonFriendUsers(_ completion: @escaping (_ success: Bool) -> Void) {
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
                    let otherUser = User()
                    otherUser.uid = document.documentID
                    if !(self.currentUserObject.friends.contains(where: {$0.uid == otherUser.uid})) && !(self.currentUserObject.requests.contains(where: {$0.uid == otherUser.uid})) && !(self.currentUserObject.requested.contains(otherUser.uid)) && currentUser != otherUser.uid {
                        print ("otherUser UID: \(otherUser.uid)")
                        otherUser.firstName = document.data()["First Name"] as! String
                        otherUser.lastName = document.data()["Last Name"] as! String
                        self.potentialFriends.append(otherUser)
                    }
                }
                completion(true)
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredPotentialFriends = potentialFriends
        } else {
            filteredPotentialFriends = potentialFriends.filter { (item: User) -> Bool in
                let fullName = "\(item.firstName) \(item.lastName)"
                return fullName.range(of: searchText, options: .caseInsensitive) != nil
            }
        }
        
        tableView.reloadData()
    }
    
    @IBAction func finishPressed(_ sender: Any) {
        for cell in selectedSet {
            cell.requestFriend()
        }
        selectedSet.removeAll()
    }
}
