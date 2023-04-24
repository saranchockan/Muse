//
//  SettingsViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/7/23.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import SwiftUI


class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var lastName: UITextField!
    
    let imagePicker = UIImagePickerController()
    var currentUserObject: User = User()
    var pictureEdited: Bool = false
    
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
        } else {
            print("Nil profile picture")
        }
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.sourceType = .photoLibrary
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func savePressed(_ sender: Any) {
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
        
        if pictureEdited {
            currentUserObject.pic = profilePicture.image
            
            let storageManager = StorageManager()
            storageManager.upload(image: profilePicture.image!)
        }
                
        let db = Firestore.firestore()
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
        let friends = currentUserObject.friends
        let db = Firestore.firestore()
        let ref = db.collection("Users")
        
        for friend in friends {
            let document = ref.document(friend.uid)
            document.updateData(["friends": FieldValue.arrayRemove([currentUserObject.uid])])
        }
        
        let requested = currentUserObject.requested
        for request in requested {
            let document = ref.document(request)
            document.updateData(["requests": FieldValue.arrayRemove([currentUserObject.uid])])
        }
        Auth.auth().currentUser?.delete()
    }
    
    @IBAction func editProfilePicture(_ sender: Any) {
        self.present(imagePicker, animated: true)
        pictureEdited = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        print("user has picked")
        self.dismiss(animated: true, completion: { () -> Void in})
        let tempImage:UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        profilePicture.image  = tempImage
    }
}

public class StorageManager: ObservableObject {
    let storage = Storage.storage()

    func upload(image: UIImage) {
        // Create a storage reference
        let storageRef = storage.reference().child("images/\(Auth.auth().currentUser!.uid).jpg")


        // Convert the image into JPEG and compress the quality to reduce its size
        let data = image.jpegData(compressionQuality: 0.2)!

        // Change the content type to jpg. If you don't, it'll be saved as application/octet-stream type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"

        // Upload the image
       
        storageRef.putData(data, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error while uploading file: ", error)
            }

            if let metadata = metadata {
                print("Metadata: ", metadata)
            }
        }
    }
    

    
    func getImage(uid: String) async  -> UIImage? {
        let reference = Storage.storage().reference().child("images/\(uid).jpg")
        do {
            let data = try await reference.data(maxSize: 1 * 1024 * 1024)
            return UIImage(data: data)
        } catch {
            return nil
        }
        
    }

}
