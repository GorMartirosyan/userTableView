//
//  TableViewCell.swift
//  userTableView
//
//  Created by Gor on 12/31/20.
//

import UIKit

class TableViewCell: UITableViewCell {
    private var imageLoadedObserver: Any?
    private var url: URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.layer.cornerRadius = 5
        imageLoadedObserver = NotificationCenter.default.addObserver(forName: ImageCache.Notification.name, object: nil, queue: .main, using: imageLoaded(_:))
    }
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var genderAndPhoneLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    override func prepareForReuse() {
        nameLabel.text = ""
        countryLabel.text = ""
        addressLabel.text = ""
        genderAndPhoneLabel.text = ""
        imgView.image = nil
    }
    
    func setUp(with data: User?) {
        guard let data = data else {return}
        nameLabel.text = (data.name?.first)! + " " + (data.name?.last)!
        countryLabel.text = data.location?.country
        addressLabel.text = (data.location?.postcode)! + " " + (data.location?.street?.name)! + " " + (data.location?.state)!
        genderAndPhoneLabel.text = data.gender!.capitalized + ", " + data.phone!
        url = data.picture?.large
        imgView.image = ImageCache.shared.image(for: (data.picture?.large)!)
        
    }
    
    private func imageLoaded(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let imageUrl = userInfo[ImageCache.Notification.url] as? URL, url == imageUrl else { return }
        imgView.image = userInfo[ImageCache.Notification.image] as? UIImage
    }
}

