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

protocol ModifyFriendsDelegate {
    func addSelectedToSet(cell: FriendCardTableViewCell)
    func removeSelectedFromSet(cell: FriendCardTableViewCell)
}

class MyFriendsViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, ModifyFriendsDelegate {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var tableData: [User] = []
    let cellIdentifier = "FriendCard"
    var currentUserObject:User = User()
    var selectedSet: Set<FriendCardTableViewCell> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentControl.frame.size.height = 45

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "FriendCard", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        tableData = self.currentUserObject.friends
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        actOnSelected(index: segmentControl.selectedSegmentIndex)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        switch segmentControl.selectedSegmentIndex {
        case 0:
            tableData = currentUserObject.friends
            if tableData.isEmpty {
                tableView.isHidden = true
                emptyLabel.text = "You have no friends"
            } else {
                tableView.reloadData()
                tableView.isHidden = false
            }
        case 1:
            tableData = currentUserObject.requests
            if tableData.isEmpty {
                tableView.isHidden = true
                emptyLabel.text = "You have no requests"
            } else {
                tableView.reloadData()
                tableView.isHidden = false
            }
        default:
            print("this isn't supposed to happen")
        }
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            actOnSelected(index: 1)
            tableData = currentUserObject.friends
            if tableData.isEmpty {
                tableView.isHidden = true
                emptyLabel.text = "You have no friends"
            } else {
                tableView.reloadData()
                tableView.isHidden = false
            }
        case 1:
            actOnSelected(index: 0)
            tableData = currentUserObject.requests
            if tableData.isEmpty {
                tableView.isHidden = true
                emptyLabel.text = "You have no requests"
            } else {
                tableView.reloadData()
                tableView.isHidden = false
            }
        default:
            print("this isn't supposed to happen")
        }
    }
    
    func actOnSelected(index: Int) {
        switch index {
        case 0:
            for cell in selectedSet {
                cell.removeFriend()
            }
            selectedSet.removeAll()
        case 1:
            for cell in selectedSet {
                cell.addFriend()
            }
            selectedSet.removeAll()
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
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendCardTableViewCell
        cell.name.text = "\(tableData[indexPath.row].firstName) \(tableData[indexPath.row].lastName)"
        cell.currentUserObject = currentUserObject
        cell.friendUID = tableData[indexPath.row].uid
        cell.delegate = self
        cell.button.isSelected = false
        cell.button.backgroundColor = UIColor(red: 31/255, green: 34/255, blue: 42/255, alpha: 1)
        if (segmentControl.selectedSegmentIndex == 0) {
            cell.button.setTitle("Remove", for: .normal)
            cell.button.setTitle("Removed", for: .selected)
        } else {
            cell.button.setTitle("Add", for: .normal)
            cell.button.setTitle("Added", for: .selected)
        }
        return cell
	}
}
