//
//  MyFriendsViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/2/23.
//

import UIKit
import FirebaseAuth

class MyFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
        return cell
    }
}
