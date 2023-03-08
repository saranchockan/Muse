//
//  SettingsViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/7/23.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var fullName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profilePicture.layer.borderColor = CGColor(red: 150/255, green: 150/255, blue: 219/255, alpha: 1)
    }

    @IBAction func logout(_ sender: Any) {
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
    }
    
    @IBAction func editProfilePicture(_ sender: Any) {
    }
}
