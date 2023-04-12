//
//  FriendCardTableViewCell.swift
//  Muse
//
//  Created by Elizabeth Snider on 4/3/23.
//

import UIKit
import FirebaseFirestore

class FriendCardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var currentUserObject: User!
    var friendUID: String!
    var friendObject: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.layer.borderColor = CGColor(red: 150/255, green: 150/255, blue: 219/255, alpha: 1)
        button.addTarget(self, action: #selector(myButtonTapped), for: UIControl.Event.touchUpInside)
        button.setTitle("Remove", for: .normal)
        button.setTitle("Removed", for: .selected)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func myButtonTapped(){
      if button.isSelected == true {
        button.isSelected = false
      }else {
        button.isSelected = true
      }
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        if !button.isSelected {
            button.backgroundColor = UIColor(red: 150/255, green: 150/255, blue: 219/255, alpha: 1)
            let index: Int = currentUserObject.friends.firstIndex(where: {$0.uid == friendUID})!
            friendObject = currentUserObject.friends[index]
            currentUserObject.friends.remove(at: index)
            let currentUserId = currentUserObject.uid
            let db = Firestore.firestore()
            let ref = db.collection("Users")
            let document = ref.document(currentUserId)
            
            document.updateData(["friends": FieldValue.arrayRemove([friendUID!])])
            
            let friendDocument = ref.document(friendUID)
            friendDocument.updateData(["friends": FieldValue.arrayRemove([currentUserId])])
        } else {
            button.backgroundColor = UIColor(red: 31/255, green: 34/255, blue: 42/255, alpha: 1)
            let currentUserId = currentUserObject.uid
            let db = Firestore.firestore()
            let ref = db.collection("Users")
            let document = ref.document(currentUserId)
            document.updateData(["friends": FieldValue.arrayUnion([friendUID!])])
            currentUserObject.friends.append(friendObject!)
        }
    }
}
