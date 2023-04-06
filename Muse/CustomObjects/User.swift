//
//  User.swift
//  Muse
//
//  Created by Richa Gadre on 4/4/23.
//

import Foundation
import UIKit

class User {
    var uid:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var location:String = ""
    var friends:[User] = []
    var requests:[User] = []
    var pic: UIImage?
}
