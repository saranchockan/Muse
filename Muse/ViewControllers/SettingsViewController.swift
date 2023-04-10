//
//  SettingsViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/7/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    let imagePicker = UIImagePickerController()
    var currentUserObject: User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstName.placeholder = currentUserObject.firstName
        lastName.placeholder = currentUserObject.lastName
        location.placeholder = currentUserObject.location
        
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
        if firstName.text != "" {
            currentUserObject.firstName = firstName.text!
        }
        if lastName.text != "" {
            currentUserObject.lastName = lastName.text!
        }
        if location.text != "" {
            currentUserObject.location = location.text!
        }
        
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        print("Current User uid: \(currentUser)")
        db.collection("Users").document(currentUser!).updateData([
            "First Name": currentUserObject.firstName,
            "Last Name": currentUserObject.lastName,
            "Location": currentUserObject.location,
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }

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
