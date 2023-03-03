//
//  ConnectSpotifyViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/2/23.
//

import UIKit
import SpotifyWebAPI

class ConnectSpotifyViewController: UIViewController {
    let SPOTIFY_CLIENT_ID_KEY: String = "SPOTIFY_CLIENT_ID"
    let SPOTIFY_CLIENT_SECRET_KEY:String = "SPOTIFY_CLIENT_SECRET"
    let SPOTIFY_AUTH_REDIRECT_URI:String = "muse://login-callback"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create an instance of SpotifyAPI
    }
    
    @IBAction func connectToSpotify(_ sender: Any) {
        let spotifyAPI = SpotifyAPI(
            authorizationManager: AuthorizationCodeFlowManager(
                clientId: ProcessInfo.processInfo.environment[self.SPOTIFY_CLIENT_ID_KEY]!, clientSecret: ProcessInfo.processInfo.environment[self.SPOTIFY_CLIENT_SECRET_KEY]!
            )
        )
        let spotifyAuthorizationURL = spotifyAPI.authorizationManager.makeAuthorizationURL(
            redirectURI: URL(string: self.SPOTIFY_AUTH_REDIRECT_URI)!,
                showDialog: true,
                state: String.randomURLSafe(length: 128),
                scopes: [
                    .userReadPlaybackState,
                    .userModifyPlaybackState,
                    .playlistModifyPrivate,
                    .playlistModifyPublic,
                    .userLibraryRead,
                    .userLibraryModify,
                    .userReadRecentlyPlayed,
                    .userTopRead,
                ]
        )!
        // You can open the URL however you like. For example, you could open
        // it in a web view instead of the browser.
        // See https://developer.apple.com/documentation/webkit/wkwebview
        UIApplication.shared.open(spotifyAuthorizationURL)
    }
}
