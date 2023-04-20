//
//  MyArtist.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/30/23.
//

import Foundation

class MyArtist: ImageCardObject {
    var artistName: String = ""
    var imgURLString: String = ""
    
    func getSongArtists() -> String {
        return ""
    }
    
    func getFriends() -> [String] {
        return []
    }
    
    func getName() -> String {
        return artistName
    }
    
    func getImage() -> String {
        return imgURLString
    }
}
