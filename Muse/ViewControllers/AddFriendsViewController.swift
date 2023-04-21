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
import Contacts

class AddFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ModifyFriendsDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentCtrl: UISegmentedControl!
    @IBOutlet weak var emptyLabel: UILabel!
    var contactsAllowed = false
    let cellIdentifier = "FriendCard"
    var currentUserObject: User!
    var potentialFriends: [User] = []
    var contacts: [User] = []
    var contactInfo: [String] = []
    var tableData: [User]!
    var filteredData: [User] = []
    var selectedSet: Set<FriendCardTableViewCell> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.register(UINib.init(nibName: "FriendCard", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        self.getContactInfo() { completion in
            if completion {
                self.getNonFriendUsers { completion in
                    if completion {
                        print ("potential friends in completion size", self.potentialFriends.count)
                        self.tableData = self.contacts
                        self.filteredData = self.tableData
                        self.tableView.reloadData()
                        if self.tableData.isEmpty {
                            self.tableView.isHidden = true
                            self.emptyLabel.text = self.contactsAllowed ? "You have requested all your contacts on the app. Check out all users to look for more potential friends!" : "You did not allow contact access. You can explore all users or change this in settings to see potential friends here!"
                        }
                    } else {
                        print("error getting potential user objects")
                    }
                }
            } else {
                print("error getting contacts")
            }
        }
    }
    
    @IBAction func onSegmentChange(_ sender: Any) {
        actOnSelected()
        switch segmentCtrl.selectedSegmentIndex {
        case 0:
            tableData = contacts
            filteredData = contacts
            if tableData.isEmpty {
                tableView.isHidden = true
                emptyLabel.text = contactsAllowed ? "You have requested all your contacts on the app. Check out all users to look for more potential friends!" : "You did not allow contact access. You can explore all users or change this in settings to see potential friends here!"
            } else {
                print ("num contacts: ", contacts.count)
                tableView.reloadData()
                tableView.isHidden = false
            }
        case 1:
            tableData = potentialFriends
            filteredData = potentialFriends
            if tableData.isEmpty {
                tableView.isHidden = true
                emptyLabel.text = "You have requested all users on the app!"
            } else {
                tableView.reloadData()
                tableView.isHidden = false
            }
        default:
            print("this isn't supposed to happen")
        }
    }
    
    
    func addSelectedToSet(cell: FriendCardTableViewCell) {
        selectedSet.insert(cell)
    }
    
    func removeSelectedFromSet(cell: FriendCardTableViewCell) {
        selectedSet.remove(cell)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendCardTableViewCell
        cell.name.text = "\(filteredData[indexPath.row].firstName) \(filteredData[indexPath.row].lastName)"
        cell.currentUserObject = currentUserObject
        cell.friendObject = filteredData[indexPath.row]
        if filteredData[indexPath.row].pic != nil{
            cell.profilePicture.image = filteredData[indexPath.row].pic
        }
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
            
            let storageManager = StorageManager()
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let otherUser = User()
                    otherUser.uid = document.documentID
                    if !(self.currentUserObject.friends.contains(where: {$0.uid == otherUser.uid})) && !(self.currentUserObject.requests.contains(where: {$0.uid == otherUser.uid})) && !(self.currentUserObject.requested.contains(otherUser.uid)) && currentUser != otherUser.uid {
                        print ("otherUser UID: \(otherUser.uid)")
                        otherUser.firstName = document.data()["First Name"] as! String
                        otherUser.lastName = document.data()["Last Name"] as! String
                        Task.init {
                            let image = await storageManager.getImage(uid: otherUser.uid)
                            otherUser.pic = image
                        }
                        self.potentialFriends.append(otherUser)
                        
                        // check if in contacts too
                        var phone = document.data()["Phone Number"] as! String
                        var email = document.data()["Email"] as! String
                        if self.contactInfo.contains(phone) || self.contactInfo.contains(email) {
                            self.contacts.append(otherUser)
                        }
                        
                    }
                }
                completion(true)
            }
        }
    }
    
    func getContactInfo(_ completion: @escaping (_ success: Bool) -> Void){
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (access, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            self.contactsAllowed = access
        }
        
        if (CNContactStore.authorizationStatus(for: CNEntityType.contacts) == .authorized) {
            
            let request = CNContactFetchRequest(keysToFetch: [
                CNContactEmailAddressesKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor
            ])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try store.enumerateContacts(with: request) {
                        (contact, stop) in
                        DispatchQueue.main.async {
                            self.contactInfo.append(contentsOf: contact.emailAddresses.map({ address in
                                address.value as String
                            }))
                            self.contactInfo.append(contentsOf: contact.phoneNumbers.map({ number in
                                "\(number.value)"
                            }))
                        }
                    }
                    completion(true)
                } catch {
                    print("contact error: \(error)")
                }
            }
        } else {
            completion(true)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredData = tableData
        } else {
            filteredData = tableData.filter { (item: User) -> Bool in
                let fullName = "\(item.firstName) \(item.lastName)"
                return fullName.range(of: searchText, options: .caseInsensitive) != nil
            }
        }
        
        tableView.reloadData()
    }
    
    func actOnSelected() {
        for cell in selectedSet {
            cell.requestFriend()
            let potentialIndex: Int = potentialFriends.firstIndex(where: {$0.uid == cell.friendObject.uid})!
            potentialFriends.remove(at: potentialIndex)
            let contactIndex: Int = contacts.firstIndex(where: {$0.uid == cell.friendObject.uid})!
            contacts.remove(at: contactIndex)
        }
        selectedSet.removeAll()
    }
    
    @IBAction func finishPressed(_ sender: Any) {
        actOnSelected()
    }
    
}
