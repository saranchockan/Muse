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
    var navigationController: UINavigationController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "ImageCardCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        let item = collectionList[index]
        let imageURL = URL(string: item.getImage())!
        
        if navigationController != nil {
            let st = UIStoryboard(name: "Main", bundle: nil)
            let popupViewController = st.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
            
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = NSData(contentsOf: imageURL)
                DispatchQueue.main.async {
                    popupViewController.img.image = UIImage(data: imageData! as Data)
                    popupViewController.blurredImg.image = UIImage(data: imageData! as Data)
                }
            }
            
            if item is SharedArtist {
                popupViewController.type = "artist"
            } else if item is SharedSong {
                popupViewController.type = "song"
                popupViewController.artist = item.getSongArtists()
            }
            
            popupViewController.name = item.getName()
            popupViewController.friends = item.getFriends()
            navigationController!.present(popupViewController, animated: false)
        }
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
