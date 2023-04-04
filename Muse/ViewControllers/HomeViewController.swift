//
//  HomeViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/2/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift


var sharedArtists:[String:SharedArtist] = [:]
var sharedSongs:[String: SharedSong] = [:]


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
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
                // Loading Screen should be false at this point
                // Reload table view
                self.printOutput()
                print("Reloading table view data...")
                self.tableView.reloadData()
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
        
        // Iterate through sharedSongs and sharedArtists
        if (sharedArtists.isEmpty && sharedSongs.isEmpty){
            self.tableView.isHidden = true
            return UITableViewCell()
        }else{
            self.tableView.isHidden = false
        }
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: sharedCellIdentifier, for: indexPath) as! SharedCardTableViewCell
            let featuredSharedArtist = sharedArtists.randomElement()
            cell.name.text = featuredSharedArtist!.key
            cell.friendsDescription.text = writeFeaturedDescription(featuredSharedArtist!.value.friends, "artist")
            cell.sharedType.text = "Featured Shared Artist"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: imageCellIdentifier, for: indexPath) as! ImageCardTableViewCell
            cell.title.text = "Who Your Friends Are Listening To"
            cell.collectionList = Array(sharedArtists.values)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: sharedCellIdentifier, for: indexPath) as! SharedCardTableViewCell
            let featuredSharedSong = sharedSongs.randomElement()
            cell.name.text = featuredSharedSong!.key
            cell.friendsDescription.text = writeFeaturedDescription(featuredSharedSong!.value.friends, "song")
            cell.sharedType.text = "Featured Shared Song"
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: imageCellIdentifier, for: indexPath) as! ImageCardTableViewCell
            cell.title.text = "Songs Your Friends Are Listening To"
            cell.collectionList = Array(sharedSongs.values)
            return cell
        default:
            print("this isn't supposed to happen")
            return UITableViewCell()
        }
    }
    
    private func writeFeaturedDescription(_ friends: [String], _ type: String) -> String{
        var desc = " also listening to this \(type)"
        switch friends.count {
        case 0:
            desc = "Nobody else is listening to this."
        case 1:
            desc = "\(friends[0]) is" + desc
        case 2:
            desc = "\(friends[0]) and \(friends[1]) are" + desc
        case 3:
            desc = "\(friends[0]), \(friends[1]), and \(friends[2]) are" + desc
        default:
            desc = "\(friends[0]), \(friends[1]), \(friends[2]), and more are"
        }
        return desc
    }
    
    func printOutput() {
        print("Shared Songs count:  \(sharedSongs.count) Shared Artists count \(sharedArtists.count)")
        for (_, sharedSong) in sharedSongs {
            print("\(sharedSong.songName) \(sharedSong.songArtists)")
            for friend in sharedSong.friends {
                print(friend)
            }
        }

        for (_, sharedArtist) in sharedArtists{
            print("\(sharedArtist.artistName)")
            for friend in sharedArtist.friends {
                print(friend)
            }
        }
    }
    
    func fetchUserSongArtistData(_ completion: @escaping (_ success: Bool) -> Void)  {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let ref = db.collection("Users")
        // Get user data from current user
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    if document.documentID == currentUser {
                        
                        // Get Top Songs, Top Artists, Friends of current user
                        let data = document.data()
                        let songs = data["Top Songs"] as! [String: String]
                        let artists = data["Top Artists"] as! [String]
                        let friends = data["friends"] as! [String]
                        
                        // Iterate through user's friends to get their Top Songs and Top Artists
                        for friend in friends {
                            ref.whereField(FieldPath.documentID(), isEqualTo: friend).getDocuments()
                            {(querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        let friendSongs = document.data()["Top Songs"] as! [String: String]
                                        let friendArtists = document.data()["Top Artists"] as! [String]
 
                                        for (song, artist) in songs {
                                            // Both users share song by same artist
                                            if artist == friendSongs[song] {
                                                if sharedSongs[song] != nil {
                                                    let currSong = sharedSongs[song]
                                                    currSong!.friends.append("\(document.data()["First Name"] as! String) \(document.data()["Last Name"] as! String)")
                                                    // Swift does not have unique keys ??
                                                    sharedSongs.removeValue(forKey: song)
                                                    sharedSongs[song] = currSong
                                                } else {
                                                    let currSong = SharedSong()
                                                    currSong.songName = song
                                                    currSong.songArtists = artist
                                                    currSong.friends = []
                                                    currSong.friends.append("\(document.data()["First Name"] as! String) \(document.data()["Last Name"] as! String)")
                                                    sharedSongs[song] = currSong
                                                }
                                            }
                                           
                                       }
                                        
                                        
                                        for artist in artists {
                                            if friendArtists.contains(artist) {
                                                if sharedArtists[artist] != nil {
                                                    let currArtist = sharedArtists[artist]
                                                    currArtist?.friends.append("\(document.data()["First Name"] as! String) \(document.data()["Last Name"] as! String)")
                                                    sharedArtists.removeValue(forKey: artist)
                                                    sharedArtists[artist] = currArtist
                                                } else {
                                                    let currArtist = SharedArtist()
                                                    currArtist.artistName = artist
                                                    currArtist.friends = []
                                                    currArtist.friends.append("\(document.data()["First Name"] as! String) \(document.data()["Last Name"] as! String)")
                                                    sharedArtists[artist] = currArtist
                                                }
                                            }
                                        }
                                        
                                        print("Shared Songs count after fetching:  \(sharedSongs.count) Shared Artists count after fetching: \(sharedArtists.count)")
                                        completion(true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}
