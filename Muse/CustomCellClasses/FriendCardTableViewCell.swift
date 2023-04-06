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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.layer.borderColor = CGColor(red: 150/255, green: 150/255, blue: 219/255, alpha: 1)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        if button.titleLabel?.text == "Remove"{
            let index: Int = currentUserObject.friends.firstIndex(where: {$0.uid == friendUID})!
            currentUserObject.friends.remove(at: index)
            var currentUserId = currentUserObject.uid
            
            let db = Firestore.firestore()
            let ref = db.collection("Users")
            
            let document = ref.document(currentUserId)
            
            document.updateData(["friends": FieldValue.arrayRemove([friendUID!])])
            
            let friendDocument = ref.document(friendUID)
            friendDocument.updateData(["friends": FieldValue.arrayRemove([currentUserId])])
            
            button.setTitle("Removed", for: .normal)
            button.backgroundColor = UIColor(red: 150/255, green: 150/255, blue: 219/255, alpha: 1)
        }
    }
}
