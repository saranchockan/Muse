//
//  SharedCardTableViewCell.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/29/23.
//

import UIKit

class SharedCardTableViewCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var sharedType: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var sharedImage: UIImageView!
    @IBOutlet weak var friendsDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
