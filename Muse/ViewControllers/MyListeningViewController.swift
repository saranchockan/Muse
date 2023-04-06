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
    var mySongs:[String: MySong] = [:]
    var myArtists:[MyArtist] = []
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
        
        if (myArtists.isEmpty && mySongs.isEmpty){
            self.tableView.isHidden = true
            return UITableViewCell()
        }else{
            self.tableView.isHidden = false
        }
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: sharedCellIdentifier, for: indexPath) as! SharedCardTableViewCell
            let featuredMyArtist = myArtists.randomElement()
            cell.name.text = featuredMyArtist?.artistName
            cell.friendsDescription.text = ""
            cell.sharedType.text = "My Featured Artist"
            fetchImages(featuredMyArtist! as ImageCardObject, cell) {
                completion in
                if completion {
                    print("images correctly fetched")
                } else {
                    print("error")
                }
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: imageCellIdentifier, for: indexPath) as! ImageCardTableViewCell
            cell.title.text = "Recently Played Tracks"
            cell.collectionList = Array(mySongs.values)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: sharedCellIdentifier, for: indexPath) as! SharedCardTableViewCell
            let featuredMySong = mySongs.randomElement()
            cell.name.text = featuredMySong?.key
            cell.friendsDescription.text = ""
            cell.sharedType.text = "My Featured Song"
            fetchImages(featuredMySong!.value as ImageCardObject, cell) {
                completion in
                if completion {
                    print("images correctly fetched")
                } else {
                    print("error")
                }
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: imageCellIdentifier, for: indexPath) as! ImageCardTableViewCell
            cell.title.text = "Recent Artists"
            cell.collectionList = myArtists
            return cell
        default:
            print("this isn't supposed to happen")
            return UITableViewCell()
        }
        
    }
    
    func printOutput() {
        for (_, songObject) in mySongs {
            print("Song name: \(songObject.songName) Song artist: \(songObject.artistName)")
        }
        
        for artist in myArtists {
            print("Artist: \(artist.artistName)")
        }
    }
    
    func fetchImages(_ item: ImageCardObject,_ cell: SharedCardTableViewCell, _ completion: @escaping (_ success: Bool) -> Void)  {
        DispatchQueue.global(qos: .userInitiated).async {
            var imageUrlStr = "https://files.radio.co/humorous-skink/staging/default-artwork.png"
            if (item.getImage() != ""){
                imageUrlStr = item.getImage()
            }
            let imageURL = URL(string: imageUrlStr)!
            let imageData = NSData(contentsOf: imageURL)
            DispatchQueue.main.async {
                cell.sharedImage.image = UIImage(data: imageData! as Data)
                cell.cardView.backgroundColor = cell.sharedImage.image?.averageColor?.lighter(by: 0.4)
            }
        }
        completion(true)
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
                        
                        let songs = data["Top Songs"] as! [String: String]
                        
                        let artists = data["Top Artists"] as! [String]
                        
                        for (song, artist) in songs {
                            let newSong = MySong()
                            newSong.songName = song
                            newSong.artistName = artist
                            self.mySongs[song] = newSong
                        }
                        
                        for artist in artists {
                            let newArtist = MyArtist()
                            newArtist.artistName = artist
                            self.myArtists.append(newArtist)
                        }
                        
                        
                    }
                    
                }
            }
            
            completion(true)
        }
    }
}
