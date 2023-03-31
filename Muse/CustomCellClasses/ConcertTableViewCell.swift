//
//  ConcertTableViewCell.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/28/23.
//

import UIKit

class ConcertTableViewCell: UITableViewCell {

    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var concertDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
