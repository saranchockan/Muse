//
//  MySong.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/30/23.
//

import Foundation

class MySong: ImageCardObject {
    var songName: String = ""
    
    var artistName: String = ""
    
    func getName() -> String {
        return songName
    }
    
    func getArtistName() -> String {
        return artistName
    }
    
    func getImage() {}
}
