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
import SpotifyWebAPI
import Combine

var sharedArtists:[String:SharedArtist] = [:]
var sharedSongs:[String: SharedSong] = [:]

protocol SpotifyProtocol {
    func processSpotifyData()
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SpotifyProtocol {
        
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var greeting: UINavigationItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    let sharedCellIdentifier = "SharedCard"
    let imageCellIdentifier = "ImageCard"
    var currentUserObject:User = User()
    public var spotify: Spotify? = nil
    private var topArtistCancellables: AnyCancellable? = nil
    var fromRegistration = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.greeting.title = "Hello, \(self.currentUserObject.firstName)"
    }

    
    override func viewDidLoad()  {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "SharedCard", bundle: nil), forCellReuseIdentifier: sharedCellIdentifier)
        tableView.register(UINib.init(nibName: "ImageCard", bundle: nil), forCellReuseIdentifier: imageCellIdentifier)
        settingsButton.isHidden = true
        
        spotify = Spotify()
        print("Configure Spotify Authorization")
        if (!(spotify!).isUserAuthSavedToKeychain()) {
            print("Authorizing Spotify...")
            self.performSegue(withIdentifier: "authorizeSpotify", sender: nil)
        } else {
            processSpotifyData()
        }

        self.getFriends { completion in
            if completion {
                print("MY FRIENDS: \(self.currentUserObject.friends.count)")
                let friendsNavVC = self.tabBarController?.viewControllers?[2] as! UINavigationController
                let friendsVC = friendsNavVC.topViewController as! MyFriendsViewController
                friendsVC.currentUserObject = self.currentUserObject
                self.greeting.title = "Hello, \(self.currentUserObject.firstName)"
                self.settingsButton.isHidden = false
                if self.currentUserObject.friends.isEmpty {
                    self.emptyLabel.isHidden = false
                }
            } else {
                print("error getting user object")
            }
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            print("Reloading table view after 5 seconds")
//            self.printOutput()
//            self.tableView.reloadData()
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "authorizeSpotify",
           let connectSpotifyVC = segue.destination as? ConnectSpotifyViewController {
            connectSpotifyVC.delegate = self
            connectSpotifyVC.spotify = spotify
        } else if segue.identifier == "settingsSegue",
            let settingsVC = segue.destination as? SettingsViewController {
            settingsVC.currentUserObject = self.currentUserObject
        }
    }
    
    func checktableData() {
        print("check table data")
        // Iterate through sharedSongs and sharedArtists
        if !(sharedArtists.isEmpty && sharedSongs.isEmpty){
            self.tableView.isHidden = false
        }
    }
    
    func processSpotifyData() {
        print("Spotify Authorized...")
        // Get user's top artists
        print("Retrieving user's top artists")
        self.processTopArtists() { processTopArtistsCompletion in
            if processTopArtistsCompletion {
                // Get user's top tracks
                print("Retrieving user's top tracks")
                self.processTopSongs() { processTopSongsCompletion in
                    if processTopSongsCompletion {
                        print("Processed top songs")
                        self.fetchUserSongArtistData { fetchUserSongArtistDataCompletion in
                            if fetchUserSongArtistDataCompletion {
                                // Loading Screen should be false at this point
                                // Reload table view
                                self.printOutput()
                                print("Reloading table view data...")
                                self.tableView.reloadData()
                            } else {
                                print("error")
                            }
                        }
                    } else {
                        print("Error processTopSongs()")
                    }
                }
            } else {
                print("Error processTopArtists()")
            }
        }
    
    }
    
    func processTopArtists(_ completion: @escaping (_ success: Bool) -> Void) {
        var topArtists = [Artist]()
        // Pull user's top artists from Spotify
        self.topArtistCancellables = spotify!.api
            .currentUserTopArtists(.shortTerm)
                    .receive(on: RunLoop.main)
                    .sink(
                        receiveCompletion: self.receiveTopArtistsCompletion(_:),
                        receiveValue: { topArtistsResponse in
                            topArtists = topArtistsResponse.items
                            // Parse top artist data
                            // Get artist name, genre?, image?
                            var topArtistNames = [String]()
                            var topArtistImages = [String:String]()
                            for artist in topArtists {
                                topArtistNames.append(artist.name)
                                topArtistImages[artist.name] = (artist.images?[0].url.absoluteString)!
                            }
                            // Load user's top artist data into Firebase
                            // Add artist to user top artist
                            self.loadTopArtistsToFirebase(topArtistNames: topArtistNames, topArtistImages: topArtistImages)
                            completion(true)
                        }
                    )
    }
    
    func processTopSongs(_ completion: @escaping (_ success: Bool) -> Void) {
        var topTracks = [Track]()
        // Pull user's top artists from Spotify
        self.topArtistCancellables = spotify!.api
            .currentUserTopTracks(.shortTerm)
                    .receive(on: RunLoop.main)
                    .sink(
                        receiveCompletion: self.receiveTopArtistsCompletion(_:),
                        receiveValue: { topTracksResponse in
                            topTracks = topTracksResponse.items
                            // Parse top artist data
                            // Get artist name, genre?, image?
                            var topSongs = [String:String]()
                            var topSongImages = [String:String]()
                            for track in topTracks {
                                topSongs[track.name] = track.artists?[0].name
                                topSongImages[track.name] = track.album?.images![0].url.absoluteString
                            }
                            // Load user's top artist data into Firebase
                            // Add artist to user top artist
                            self.loadTopSongsToFirebase(topSongs: topSongs, topSongImages: topSongImages)
                            completion(true)
                        }
                    )
    }
    
    func loadTopSongsToFirebase(topSongs: [String: String], topSongImages: [String: String]) {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let ref = db.collection("Users")
        let document = ref.document(currentUser!)
        document.setData(["Top Songs": topSongs], merge: true)
        document.setData(["Top Song Images": topSongImages], merge: true)
        print("Added user's top songs to Firebase: \(topSongs)")
        print("Added user's top song images to Firebase: \(topSongImages)")
    }
    
    func loadTopArtistsToFirebase(topArtistNames: [String], topArtistImages: [String:String]) {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let ref = db.collection("Users")
        let document = ref.document(currentUser!)
        document.setData(["Top Artists": topArtistNames], merge: true)
        document.setData(["Top Artist Images": topArtistImages], merge: true)
        
        print("Added user's top artists to Firebase: \(topArtistNames)")
        print("Added user's top artists images to Firebase: \(topArtistImages)")
    }
    
    func receiveTopArtistsCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        if case .failure(let error) = completion {
            print("Couldn't retrieve top artists: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        print("row \(row)")
        
        if (sharedArtists.isEmpty && sharedSongs.isEmpty){
            self.tableView.isHidden = true
            return UITableViewCell()
        } else {
            self.tableView.isHidden = false
        }
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: sharedCellIdentifier, for: indexPath) as! SharedCardTableViewCell
            if !sharedArtists.isEmpty {
                let featuredSharedArtist = sharedArtists.randomElement()
                cell.name.text = featuredSharedArtist!.key
                cell.friendsDescription.text = writeFeaturedDescription(featuredSharedArtist!.value.friends, "artist")
                cell.sharedType.text = "Featured Shared Artist"
                fetchImages(featuredSharedArtist!.value as ImageCardObject, cell) {
                    completion in
                    if completion {
                        print("images correctly fetched")
                    } else {
                        print("error")
                    }
                }
                cell.cardView.isHidden = false
                cell.emptyLabel.isHidden = true
            } else {
                print("case 0")
                cell.cardView.isHidden = true
                cell.sharedType.text = "Featured Shared Artist"
                cell.emptyLabel.text = "You do not have any shared artists"
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: imageCellIdentifier, for: indexPath) as! ImageCardTableViewCell
            cell.title.text = "Who Your Friends Are Listening To"
            cell.collectionList = Array(sharedArtists.values)
            cell.collectionView.reloadData()
            cell.navigationController = self.navigationController
            if !sharedArtists.isEmpty {
                cell.emptyLabel.isHidden = true
                cell.collectionView.isHidden = false
            } else {
                print("case 1")
                cell.collectionView.isHidden = true
                cell.emptyLabel.isHidden = false
                cell.emptyLabel.text = "You do not have any shared artists"
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: sharedCellIdentifier, for: indexPath) as! SharedCardTableViewCell
            if !sharedSongs.isEmpty {
                let featuredSharedSong = sharedSongs.randomElement()
                cell.name.text = featuredSharedSong!.key
                cell.friendsDescription.text = writeFeaturedDescription(featuredSharedSong!.value.friends, "song")
                cell.sharedType.text = "Featured Shared Song"
                fetchImages(featuredSharedSong!.value as ImageCardObject, cell) {
                    completion in
                    if completion {
                        print("images correctly fetched")
                    } else {
                        print("error")
                    }
                }
                cell.cardView.isHidden = false
                cell.emptyLabel.isHidden = true
            } else {
                print("case 2")
                cell.sharedType.text = "Featured Shared Song"
                cell.cardView.isHidden = true
                cell.emptyLabel.text = "You do not have any shared songs"
                
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: imageCellIdentifier, for: indexPath) as! ImageCardTableViewCell
            cell.title.text = "Songs Your Friends Are Listening To"
            cell.collectionList = Array(sharedSongs.values)
            cell.collectionView.reloadData()
            cell.navigationController = self.navigationController
            if !sharedSongs.isEmpty {
                cell.emptyLabel.isHidden = true
                cell.collectionView.isHidden = false
            } else {
                print("case 3")
                cell.collectionView.isHidden = true
                cell.emptyLabel.isHidden = false
                cell.emptyLabel.text = "You do not have any shared songs"
            }
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
    
    func printSharedSongData  (){
        print("shared songs")
        for sharedSong in sharedSongs.values {
                print(sharedSong.songName)
                for friend in sharedSong.friends {
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
                        let artistsImages = data["Top Artist Images"] as! [String: String]
                        let songImages = data["Top Song Images"] as! [String: String]
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
                                                    print("Song Name: ", song)
                                                    if let songImageURL =  songImages[song] {
                                                        currSong.imgURLString = songImageURL
                                                    }
                                                    currSong.friends = []
                                                    currSong.friends.append("\(document.data()["First Name"] as! String) \(document.data()["Last Name"] as! String)")
                                                    sharedSongs[song] = currSong
                                                }
                                            }
                                       }
                                        
                                        self.printSharedSongData()
                                        
                                   
                                        
                                     
                                        
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
                                                    currArtist.imgURLString = artistsImages[artist]!
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
//                        print("Shared Songs count:  \(sharedSongs.count) Shared Artists count \(sharedArtists.count)")
//                        completion(true)
                    }
                }
            }
        }
    }
    
    func getFriends(_ completion: @escaping (_ success: Bool) -> Void) {
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
                        self.currentUserObject.uid = currentUser!
                        self.currentUserObject.firstName = "\(document.data()["First Name"]!)"
                        self.currentUserObject.lastName = "\(document.data()["Last Name"]!)"
                        self.currentUserObject.location = "\(document.data()["Location"]!)"
                        self.currentUserObject.requested = document.data()["requested"] as! [String]
                        
                        let data = document.data()
                        let friends = data["friends"] as! [String]
                        let requests = data["requests"] as! [String]
                        
                        let storageManager = StorageManager()
                        
                        for friend in friends {
                            ref.whereField(FieldPath.documentID(), isEqualTo: friend).getDocuments()
                            {(querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        let currentFriend = User()
                                        currentFriend.uid = document.documentID
                                        print ("friend UID: \(currentFriend.uid)")
                                        currentFriend.firstName = document.data()["First Name"] as! String
                                        currentFriend.lastName = document.data()["Last Name"] as! String
                                        Task.init {
                                            let image = await storageManager.getImage(uid: currentFriend.uid)
                                            currentFriend.pic = image
                                        }
                                        self.currentUserObject.friends.append(currentFriend)
                                    }
                                }
                            }
                        }
                        
                        for request in requests {
                            ref.whereField(FieldPath.documentID(), isEqualTo: request).getDocuments()
                            {(querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        let currentRequest = User()
                                        currentRequest.uid = document.documentID
                                        print ("request UID: \(currentRequest.uid)")
                                        currentRequest.firstName = document.data()["First Name"] as! String
                                        currentRequest.lastName = document.data()["Last Name"] as! String
                                        Task.init {
                                            let image = await storageManager.getImage(uid: currentRequest.uid)
                                            currentRequest.pic = image
                                        }
                                        self.currentUserObject.requests.append(currentRequest)
                                    }
                                }
                            }
                        }
                        Task.init {
                            let image = await storageManager.getImage(uid: currentUser!)
                            self.currentUserObject.pic = image
                            completion (true)
                        }
                    }
                }
            }
        }
    }
}
