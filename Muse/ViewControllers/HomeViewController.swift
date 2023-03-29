//
//  HomeViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/2/23.
//

import UIKit
import SpotifyWebAPI
import Combine

class HomeViewController: UIViewController {
    
    // Spotify Model
    public let spotify: Spotify = Spotify()
    var connectSpotifyViewController = ConnectSpotifyViewController()
    var topArtists = [Artist]()
    public var cancellables: AnyCancellable? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (!connectSpotifyViewController.spotify.isAuthorized) {
            print("Reauthorizing Spotify...")
            self.performSegue(withIdentifier: "reauthorizeSpotify", sender: nil)
        } else {
            print("Spotify Authorized...")
            self.cancellables = self.spotify.api
                .currentUserTopArtists(.shortTerm)
                        .receive(on: RunLoop.main)
                        .sink(
                            receiveCompletion: self.receiveTopArtistsCompletion(_:),
                            receiveValue: { topArtists in
                                let artists = topArtists.items
                                self.topArtists = artists
                                print("Artists", artists)
                            }
                        )
        }
    }
    
    func receiveTopArtistsCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        if case .failure(let error) = completion {
            print("Couldn't retrieve top artists: \(error)")
        }
    }
    
    func handleURL(_ url: URL) {
        
    }
}
