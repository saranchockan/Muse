//
//  MySong.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/30/23.
//

import Foundation

class MySong: ImageCardObject {
    var songName: String = ""
    var imgURLString: String = ""
    var artistName: String = ""
    
    func getSongArtists() -> String {
        return ""
    }
    
    func getFriends() -> [String] {
        return []
    }
    
    func getName() -> String {
        return songName
    }
    
    func getImage() -> String {
        return imgURLString
    }
    func getArtistName() -> String {
        return artistName
    }    
}
