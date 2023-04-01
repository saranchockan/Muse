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
    public var cancellables: AnyCancellable? = nil
    private var urlRedirectCallbackCancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let spotify: Spotify = connectSpotifyViewController.spotify
        if (!spotify.isAuthorized) {
            print("Reauthorizing Spotify...")
            self.performSegue(withIdentifier: "reauthorizeSpotify", sender: nil)
        } else {
            print("Spotify Authorized...")
            self.processTopArtists()
            
        }
    }
    
    func processTopArtists() {
        let spotify: Spotify = connectSpotifyViewController.spotify
        var topArtists = [Artist]()
        // Pull user's top artists from Spotify
        self.cancellables = spotify.api
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
                            let currentUser = Auth.auth().currentUser?.uid
                            let db = Firestore.firestore()
                            let ref = db.collection("Users")
                            var document = ref.document(currentUser!)
                            
                            document.setData(["Top Artists": topArtistNames])
                            print("Added user's top artists to Firebase: \(topArtistNames)")
                            
                        }
                    )
    }
    
    func receiveTopArtistsCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        if case .failure(let error) = completion {
            print("Couldn't retrieve top artists: \(error)")
        }
    }
    
    func handleURL(_ url: URL) {
        let spotify: Spotify = connectSpotifyViewController.spotify

        // **Always** validate URLs; they offer a potential attack vector into
        // your app.
        guard url.scheme == spotify.loginCallbackURL.scheme else {
            print("not handling URL: unexpected scheme: '\(url)'")
            return
        }
        
        print("received redirect from Spotify: '\(url)'")
        
        // This property is used to display an activity indicator in `LoginView`
        // indicating that the access and refresh tokens are being retrieved.
        spotify.isRetrievingTokens = true
        
        // Complete the authorization process by requesting the access and
        // refresh tokens.
        spotify.api.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            // This value must be the same as the one used to create the
            // authorization URL. Otherwise, an error will be thrown.
            state: spotify.authorizationState
        )
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            // Whether the request succeeded or not, we need to remove the
            // activity indicator.
            spotify.isRetrievingTokens = false
            
            /*
             After the access and refresh tokens are retrieved,
             `SpotifyAPI.authorizationManagerDidChange` will emit a signal,
             causing `Spotify.authorizationManagerDidChange()` to be called,
             which will dismiss the loginView if the app was successfully
             authorized by setting the @Published `Spotify.isAuthorized`
             property to `true`.

             The only thing we need to do here is handle the error and show it
             to the user if one was received.
             */
            if case .failure(let error) = completion {
                print("couldn't retrieve access and refresh tokens:\n\(error)")
                if let authError = error as? SpotifyAuthorizationError,
                   authError.accessWasDenied {
                    print("You Denied The Authorization Request :(")
                }
                else {
                    print("Couldn't Authorization With Your Account")
                }
            }
        })
        .store(in: &urlRedirectCallbackCancellables)
        
        // MARK: IMPORTANT: generate a new value for the state parameter after
        // MARK: each authorization request. This ensures an incoming redirect
        // MARK: from Spotify was the result of a request made by this app, and
        // MARK: and not an attacker.
        spotify.authorizationState = String.randomURLSafe(length: 128)
        
    }
}
