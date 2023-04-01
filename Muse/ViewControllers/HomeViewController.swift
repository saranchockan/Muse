//
//  HomeViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/2/23.
//

import UIKit
import SpotifyWebAPI
import Combine
import Firebase
import FirebaseAuth

class HomeViewController: UIViewController {
    
    // Spotify Model
    var connectSpotifyViewController = ConnectSpotifyViewController()
    private var topArtistCancellables: AnyCancellable? = nil
    private var urlRedirectCallbackCancellables: Set<AnyCancellable> = []
    private var spotifyAuthAccessRequestStatus: SpotifyAuthRequestStatus = SpotifyAuthRequestStatus.REQUESTED
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let spotify: Spotify = connectSpotifyViewController.spotify
        if (!spotify.isAuthorized) {
            print("Authorizing Spotify...")
            self.performSegue(withIdentifier: "reauthorizeSpotify", sender: nil)
        } else {
            processSpotifyData()
        }
        
    }
    
    func processSpotifyData() {
        print("Spotify Authorized...")
        // Get user's top artists
        print("Retrieving user's top artists")
        self.processTopArtists()
        
        // Get user's top tracks
        print("Retrieving user's top tracks")
    }
    
    func processTopArtists() {
        let spotify: Spotify = connectSpotifyViewController.spotify
        var topArtists = [Artist]()
        // Pull user's top artists from Spotify
        self.topArtistCancellables = spotify.api
            .currentUserTopArtists(.shortTerm)
                    .receive(on: RunLoop.main)
                    .sink(
                        receiveCompletion: self.receiveTopArtistsCompletion(_:),
                        receiveValue: { topArtistsResponse in
                            topArtists = topArtistsResponse.items
                            // Parse top artist data
                            // Get artist name, genre?, image?
                            var topArtistNames = [String]()
                            for artist in topArtists {
                                topArtistNames.append(artist.name)
                            }
                            // Load user's top artist data into Firebase
                            // Add artist to user top artist
                            self.loadTopArtistsToFirebase(topArtistNames: topArtistNames)
                        }
                    )
    }
    
    func loadTopArtistsToFirebase(topArtistNames: [String]) {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let ref = db.collection("Users")
        let document = ref.document(currentUser!)
        document.setData(["Top Artists": topArtistNames])
        print("Added user's top artists to Firebase: \(topArtistNames)")
    }
    
    func receiveTopArtistsCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        if case .failure(let error) = completion {
            print("Couldn't retrieve top artists: \(error)")
        }
    }
}
