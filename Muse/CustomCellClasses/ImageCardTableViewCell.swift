//
//  ImageCardTableViewCell.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/30/23.
//

import UIKit

class ImageCardTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var title: UILabel!
    var cellIdentifier = "ImageCardCell"
    var collectionList : [ImageCardObject]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "ImageCardCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCardCell", for: indexPath) as! ImageCardCollectionViewCell
        let row = indexPath.row
        cell.label.text = collectionList[row].getName()
        fetchImages(collectionList[row], cell) { completion in
            if completion {
                print("images correctly fetched")
            } else {
                print("error")
            }
        }
        return cell
    }
    
    func fetchImages(_ item: ImageCardObject,_ cell: ImageCardCollectionViewCell, _ completion: @escaping (_ success: Bool) -> Void)  {
        DispatchQueue.global(qos: .userInitiated).async {
            var imageUrlStr = "https://files.radio.co/humorous-skink/staging/default-artwork.png"
            if (item.getImage() != ""){
                imageUrlStr = item.getImage()
            }
            let imageURL = URL(string: imageUrlStr)!
            let imageData = NSData(contentsOf: imageURL)
            DispatchQueue.main.async {
                cell.img.image = UIImage(data: imageData! as Data)
            }
        }
        completion(true)
    }
}
