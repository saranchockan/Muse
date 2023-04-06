//
//  SettingsViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/7/23.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var fullName: UITextField!
    
    let imagePicker: UIImagePickerController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profilePicture.layer.borderColor = CGColor(red: 150/255, green: 150/255, blue: 219/255, alpha: 1)
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        
        print("media types: \(UIImagePickerController.availableMediaTypes(for: .photoLibrary))")
    }

    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign out error")
        }
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        Auth.auth().currentUser?.delete()
    }
    
    @IBAction func editProfilePicture(_ sender: Any) {
    }
}
