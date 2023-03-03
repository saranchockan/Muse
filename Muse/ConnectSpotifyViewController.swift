//
//  ConnectSpotifyViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/2/23.
//

import UIKit
import SpotifyWebAPI

class ConnectSpotifyViewController: UIViewController {
    let SPOTIFY_CLIENT_ID = "658a9575d9cf4542a28d885c7000b725"
    let SPOTIFY_CLIENT_SECRET = "46219117f32042b9a217cde1d3155a09"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create an instance of SpotifyAPI
    }
    
    @IBAction func connectToSpotify(_ sender: Any) {
        let spotifyAPI = SpotifyAPI(
            authorizationManager: AuthorizationCodeFlowManager(
                clientId: self.SPOTIFY_CLIENT_ID, clientSecret: self.SPOTIFY_CLIENT_SECRET
            )
        )
        let url = spotifyAPI.authorizationManager.makeAuthorizationURL(
            redirectURI: URL(string: "muse://login-callback")!,
                    showDialog: true,
                    state: String.randomURLSafe(length: 128),
                    scopes: [
                        .userReadPlaybackState,
                        .userModifyPlaybackState,
                        .playlistModifyPrivate,
                        .playlistModifyPublic,
                        .userLibraryRead,
                        .userLibraryModify,
                        .userReadRecentlyPlayed
                    ]
                )!
                
                // You can open the URL however you like. For example, you could open
                // it in a web view instead of the browser.
                // See https://developer.apple.com/documentation/webkit/wkwebview
                UIApplication.shared.open(url)
    }
    
    
    
}
