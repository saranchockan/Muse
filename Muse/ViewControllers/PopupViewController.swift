//
//  PopupViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 4/20/23.
//

import UIKit

class PopupViewController: UIViewController {

    @IBOutlet weak var friendDescription: UILabel!
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var blurredImg: UIImageView!
    var name: String?
    var artist: String?
    var friends: [String] = []
    var type: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overCurrentContext
        
        backgroundView.isOpaque = false
        backgroundView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = blurredImg.bounds
        blurredImg.addSubview(blurView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PopupViewController.handleTap(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        blurredImg.image = img.image
        
        if type == "artist" {
            cardTitle.text = name
            friendDescription.text = writeDescription(friends, type)
        } else if type == "song", let title = name, let artists = artist {
            cardTitle.text = title + "\n" + artists
            friendDescription.text = writeDescription(friends, type)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: false, completion: nil)
    }
    
    private func writeDescription(_ friends: [String], _ type: String) -> String{
        var desc = " also listening to this \(type)"
        switch friends.count {
        case 0:
            desc = "Nobody else is listening to this."
        case 1:
            desc = "\(friends[0]) is" + desc
        case 2:
            desc = "\(friends[0]) and \(friends[1]) are" + desc
        case 3:
            desc = "\(friends[0]), \(friends[1]), and \(friends[2]) are" + desc
        default:
            desc = "\(friends[0]), \(friends[1]), \(friends[2]), and more are"
        }
        return desc
    }

}
