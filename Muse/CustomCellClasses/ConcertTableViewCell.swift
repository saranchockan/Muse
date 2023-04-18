//
//  ConcertTableViewCell.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/28/23.
//

import UIKit

class ConcertTableViewCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var concertDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        artistName.adjustsFontSizeToFitWidth = true
        concertDescription.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
