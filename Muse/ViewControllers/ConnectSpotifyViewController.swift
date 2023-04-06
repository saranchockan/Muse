//
//  ConnectSpotifyViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/2/23.
//

import UIKit
import SpotifyWebAPI
import Combine

weak var connectSpotifyViewControllerInstance = ConnectSpotifyViewController()

class ConnectSpotifyViewController: UIViewController {
    let SPOTIFY_CLIENT_ID_KEY: String = "SPOTIFY_CLIENT_ID"
    let SPOTIFY_CLIENT_SECRET_KEY:String = "SPOTIFY_CLIENT_SECRET"
    let SPOTIFY_AUTH_REDIRECT_URI:String = "muse://login-callback"
        
    @IBOutlet weak var connectButton: UIButton!
    var delegate: UIViewController!
    var spotify: Spotify!
    
    public var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create an instance of SpotifyAPI
        connectButton.layer.borderColor = CGColor(red: 150/255, green: 150/255, blue: 219/255, alpha: 1)
        connectSpotifyViewControllerInstance = self
    }
    
    @IBAction func connectToSpotify(_ sender: Any) {
        spotify.authorize()
    }
    
    func handleURL(_ url: URL) {
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
            self.spotify.isRetrievingTokens = false
            
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
            } else {
                let homeVC = self.delegate as! HomeViewController
                homeVC.processSpotifyData() 
                
            }
            self.dismiss(animated: true, completion: nil)
        })
        .store(in: &cancellables)
        
        // MARK: IMPORTANT: generate a new value for the state parameter after
        // MARK: each authorization request. This ensures an incoming redirect
        // MARK: from Spotify was the result of a request made by this app, and
        // MARK: and not an attacker.
        spotify.authorizationState = String.randomURLSafe(length: 128)
        
    }
}
