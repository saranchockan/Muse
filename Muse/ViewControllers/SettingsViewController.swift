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
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    let imagePicker = UIImagePickerController()
    var currentUserObject: User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstName.text = currentUserObject.firstName
        lastName.text = currentUserObject.lastName
        location.text = currentUserObject.location
        
        let firstPaddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 31))
        firstName.leftView = firstPaddingView
        firstName.leftViewMode = .always
        let secondPaddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 31))
        lastName.leftView = secondPaddingView
        lastName.leftViewMode = .always
        let thirdPaddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 31))
        location.leftView = thirdPaddingView
        location.leftViewMode = .always

        if currentUserObject.pic != nil{
            profilePicture.image = currentUserObject.pic
        }
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.sourceType = .photoLibrary
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //send stuff back to firebase
    }

    @IBAction func logout(_ sender: Any) {
        sharedArtists = [:]
        sharedSongs = [:]
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign out error")
        }
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        sharedArtists = [:]
        sharedSongs = [:]
        Auth.auth().currentUser?.delete()
    }
    
    @IBAction func editProfilePicture(_ sender: Any) {
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        print("user has picked")
        self.dismiss(animated: true, completion: { () -> Void in})
        let tempImage:UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        profilePicture.image  = tempImage
        currentUserObject.pic = tempImage
    }
}
