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

class MyListeningViewController: UIViewController {
    
    var mySongs:[String: String] = [:]
    var myArtists:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchUserSongArtistData { completion in
            if completion {
                self.printOutput()
            } else {
                print("error")
            }
            
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
