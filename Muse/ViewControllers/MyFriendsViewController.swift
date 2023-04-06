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

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var tableData: [User] = []
    let cellIdentifier = "FriendCard"
    var currentUserObject:User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)

        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "FriendCard", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        tableData = self.currentUserObject.friends
        tableView.reloadData()
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendCardTableViewCell
        cell.name.text = "\(tableData[indexPath.row].firstName) \(tableData[indexPath.row].lastName)"
        cell.currentUserObject = currentUserObject
        cell.friendUID = tableData[indexPath.row].uid
        if (segmentControl.selectedSegmentIndex == 0) {
            cell.button.setTitle("Remove", for: .normal)
        } else {
            cell.button.setTitle("Add", for: .normal)
        }
        return cell
	}
}
