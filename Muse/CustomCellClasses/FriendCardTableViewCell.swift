//
//  FriendCardTableViewCell.swift
//  Muse
//
//  Created by Elizabeth Snider on 4/3/23.
//

import UIKit

class FriendCardTableViewCell: UITableViewCell {

    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        removeButton.layer.borderColor = CGColor(red: 150/255, green: 150/255, blue: 219/255, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func removePressed(_ sender: Any) {
    }
}
