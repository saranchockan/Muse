//
//  SharedArtist.swift
//  Muse
//
//  Created by Richa Gadre on 3/28/23.
//

import Foundation

class SharedArtist: ImageCardObject {
    var artistName: String = ""
    var friends:[String] = []
    
    func getName() -> String {
        return artistName
    }
    
    func getImage() {}
}
