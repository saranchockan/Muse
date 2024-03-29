//
//  SharedSong.swift
//  Muse
//
//  Created by Richa Gadre on 3/27/23.
//

import Foundation

protocol ImageCardObject{
    func getName() -> String
    func getImage() -> String
    func getFriends() -> [String]
    func getSongArtists() -> String
}

class SharedSong : ImageCardObject {

    var songName:String = ""
    var songArtists:String = ""
    var friends:[String] = []
    var imgURLString: String = ""
    
    func getSongArtists() -> String {
        return songArtists
    }
    
    func getFriends() -> [String] {
        return friends
    }
    
    func getName() -> String {
        return songName
    }
    
    func getImage() -> String {
        return imgURLString
    }
}
