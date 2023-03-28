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

class HomeViewController: UIViewController {
    
    var sharedSongs:[String: SharedSong] = [:]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchUserData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func fetchUserData() {
        
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
                        
                        
                        let friends = data["friends"] as! [String]
                        
                        
                        for friend in friends {
                            print("Friend: \(friend)")
                            ref.whereField(FieldPath.documentID(), isEqualTo: friend).getDocuments()
                            {(querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        let friendSongs = document.data()["Top Songs"] as! [String: String]
 
                                        for (song, artist) in songs {
                                           if friendSongs[song] != nil {
                                                let artistIsSame = artist == friendSongs[song]
                                                if artistIsSame {
                                                    if self.sharedSongs[song] != nil {
                                                        let currSong = self.sharedSongs[song]
                                                        currSong?.friends.append(document.data()["First Name"] as! String)
                                                        self.sharedSongs.removeValue(forKey: song)
                                                        self.sharedSongs[song] = currSong
                                                    } else {
                                                        let currSong = SharedSong()
                                                        currSong.songName = song
                                                        currSong.songArtists = artist
                                                        currSong.friends = []
                                                        currSong.friends.append(document.data()["First Name"] as! String)
                                                        self.sharedSongs[song] = currSong
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
            }
        }
    }
    
}
