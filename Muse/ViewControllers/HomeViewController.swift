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

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var sharedSongs:[String: SharedSong] = [:]
    var sharedArtists:[String: SharedArtist] = [:]
    let sharedCellIdentifier = "SharedCard"
    let imageCellIdentifier = "ImageCard"
    
    override func viewWillAppear(_ animated: Bool)  {
        super.viewWillAppear(true)
        print("View will appear")
        
        self.fetchUserSongArtistData { completion in
            if completion {
                self.printOutput()
            } else {
                print("error")
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "SharedCard", bundle: nil), forCellReuseIdentifier: sharedCellIdentifier)
        tableView.register(UINib.init(nibName: "ImageCard", bundle: nil), forCellReuseIdentifier: imageCellIdentifier)
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
            cell.sharedType.text = "Top Shared Artist"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: imageCellIdentifier, for: indexPath) as! ImageCardTableViewCell
            cell.title.text = "Who Your Friends Are Listening To"
            cell.collectionList = Array(sharedArtists.values)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: sharedCellIdentifier, for: indexPath) as! SharedCardTableViewCell
            cell.name.text = "Montero"
            cell.friendsDescription.text = "Saahithi and Liz are listening to this album"
            cell.sharedType.text = "Top Shared Album"
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: imageCellIdentifier, for: indexPath) as! ImageCardTableViewCell
            cell.title.text = "Songs Your Friends Are Listening To"
            cell.collectionList = Array(sharedArtists.values)
            return cell
        default:
            print("this isn't supposed to happen")
            return UITableViewCell()
        }
        
    }
    
    func printOutput() {
        print("Shared Songs count:  \(self.sharedSongs.count) Shared Artists count \(self.sharedArtists.count)")
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
        
        /* Note: currently is getting the PREVIOUS log in because we have to wait to authenticate*/
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
                        
                        let songs = data["Top Songs"] as! [String: String]
                        
                        let artists = data["Top Artists"] as! [String]
                        
                        
                        let friends = data["friends"] as! [String]
                        
                        
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
                                           if friendSongs[song] != nil {
                                                let artistIsSame = artist == friendSongs[song]
                                                if artistIsSame {
                                                    if self.sharedSongs[song] != nil {
                                                        var currSong = self.sharedSongs[song]
                                                        currSong!.friends.append("\(document.data()["First Name"] as! String) \(document.data()["Last Name"] as! String)")
                                                        self.sharedSongs.removeValue(forKey: song)
                                                        self.sharedSongs[song] = currSong
                                                    } else {
                                                        let currSong = SharedSong()
                                                        currSong.songName = song
                                                        currSong.songArtists = artist
                                                        currSong.friends = []
                                                        currSong.friends.append("\(document.data()["First Name"] as! String) \(document.data()["Last Name"] as! String)")
                                                        self.sharedSongs[song] = currSong
                                                    }
                                                }
                                           }
                                       }
                                        
                                        
                                        for artist in artists {
                                            if friendArtists.contains(artist) {
                                                if self.sharedArtists[artist] != nil {
                                                    let currArtist = self.sharedArtists[artist]
                                                    currArtist?.friends.append("\(document.data()["First Name"] as! String) \(document.data()["Last Name"] as! String)")
                                                    self.sharedArtists.removeValue(forKey: artist)
                                                    self.sharedArtists[artist] = currArtist
                                                } else {
                                                    let currArtist = SharedArtist()
                                                    currArtist.artistName = artist
                                                    currArtist.friends = []
                                                    currArtist.friends.append("\(document.data()["First Name"] as! String) \(document.data()["Last Name"] as! String)")
                                                    self.sharedArtists[artist] = currArtist
                                                }
                                            }
                                        }
                                        
                                        print("Shared Songs count after fetching:  \(self.sharedSongs.count) Shared Artists count after fetching: \(self.sharedArtists.count)")
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
