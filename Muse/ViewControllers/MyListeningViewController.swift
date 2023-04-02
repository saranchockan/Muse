//
//  MyListeningViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/2/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class MyListeningViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var mySongs:[String: String] = [:]
    var myArtists:[String] = []
    let sharedCellIdentifier = "SharedCard"
    let imageCellIdentifier = "ImageCard"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "SharedCard", bundle: nil), forCellReuseIdentifier: sharedCellIdentifier)
        tableView.register(UINib.init(nibName: "ImageCard", bundle: nil), forCellReuseIdentifier: imageCellIdentifier)
        
        self.fetchUserSongArtistData { completion in
            if completion {
                self.printOutput()
            } else {
                print("error")
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: sharedCellIdentifier, for: indexPath) as! SharedCardTableViewCell
            cell.name.text = "Justin Bieber"
            cell.friendsDescription.text = "Saahithi and Liz are listening to this artist"
            cell.sharedType.text = "My Top Artist"
            return cell
//        case 1:
//            let cell = tableView.dequeueReusableCell(withIdentifier: imageCellIdentifier, for: indexPath) as! ImageCardTableViewCell
//            cell.title.text = "Recently Played Tracks"
//            cell.collectionList = Array(mySongs.values)
//            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: sharedCellIdentifier, for: indexPath) as! SharedCardTableViewCell
            cell.name.text = "Montero"
            cell.friendsDescription.text = "Saahithi and Liz are listening to this album"
            cell.sharedType.text = "My Top Genre"
            return cell
//        case 3:
//            let cell = tableView.dequeueReusableCell(withIdentifier: imageCellIdentifier, for: indexPath) as! ImageCardTableViewCell
//            cell.title.text = "Recommended Music"
//            cell.collectionList = myArtists
//            return cell
        default:
            print("this isn't supposed to happen")
            return UITableViewCell()
        }
        
    }
    
    func printOutput() {
        for (song, artist) in mySongs {
            print("Song name: \(song) Song artist: \(artist)")
        }
        
        for artist in myArtists {
            print("Artist: \(artist)")
        }
    }
    
    func fetchUserSongArtistData(_ completion: @escaping (_ success: Bool) -> Void)  {
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
                        
                        let data = document.data()
                        
                        self.mySongs = data["Top Songs"] as! [String: String]
                        
                        self.myArtists = data["Top Artists"] as! [String]
                        
                        
                    }
                    
                }
            }
            
            completion(true)
        }
    }
}
