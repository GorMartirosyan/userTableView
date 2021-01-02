//
//  DetailViewController.swift
//  userTableView
//
//  Created by Gor on 12/31/20.
//

import UIKit
import MapKit
import CoreLocation
import Nominatim

protocol DetailViewControllerDelegate: class {
    func saveUser(_ user: User)
    func removeUser(_ user: User)
}

class DetailViewController: UIViewController{
    
    var user : User?
    var pin : MyAnnotation!
    weak var delegate: DetailViewControllerDelegate?
    private var imageLoadedObserver: Any?
    private var url: URL?
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var genderAndPhoneLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var saveUserOutlet: UIButton!
    @IBOutlet var removeUserOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinLocation()
        setUpLabels()
        setUpNavTitle()
        setUpImageAndButton()
        mapView.delegate = self
        
        imageLoadedObserver = NotificationCenter.default.addObserver(forName: ImageCache.Notification.name, object: nil, queue: .main, using: imageLoaded(_:))
    }
    
    func setUpImageAndButton(){
        url = user?.picture?.large
        guard let imageUrl = user?.picture?.large else {return}
        imgView.image = ImageCache.shared.image(for: imageUrl)
        imgView.layer.cornerRadius = imgView.frame.height / 2
        imgView.clipsToBounds = true
        saveUserOutlet.layer.cornerRadius = 25
    }
    
    func setUpLabels(){
        guard let user = user else {return}
        nameLabel.text = (user.name?.first)! + " " +  (user.name?.last)!
        genderAndPhoneLabel.text = user.gender! + ", " + user.phone!
        countryLabel.text = user.location?.country
        addressLabel.text = String((user.location?.street?.number)!) + " " + (user.location?.street?.name)! + " " + (user.location?.city)!
    }
    
    func setUpNavTitle(){
        guard let user = user else {return}
        self.navigationItem.title = (user.name?.first)! + " " +  (user.name?.last)!
    }
    
    func pinLocation(){
        let address = String((user?.location?.street?.number)!) + " "  + (user?.location?.street?.name)! + ", " +  (user?.location?.country)!
        
        DispatchQueue.global().async {
            Nominatim.getLocation(fromAddress: address, completion: {(location) -> Void in
                DispatchQueue.main.async {
                    
                    if let location = location {
                        guard let lat = Double((location.latitude)) else {return}
                        guard let lon = Double((location.longitude)) else {return}
                        
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
                        self.mapView.setRegion(region, animated: true)
                        
                        self.pin = MyAnnotation(coordinate: coordinate)
                        self.mapView.addAnnotation(self.pin)
                        
                    }
                    else {
                        let alert = UIAlertController(title: "Error! ", message: "Problem loading location", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        alert.show()
                    }
                }
            })
        }
    }
    
    private func imageLoaded(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let imageUrl = userInfo[ImageCache.Notification.url] as? URL, url == imageUrl else { return }
        imgView.image = userInfo[ImageCache.Notification.image] as? UIImage
    }
    
    var isSaved : Bool! {
        didSet {
            if isSaved {
                saveUserOutlet.isEnabled = false
                removeUserOutlet.isHidden = false
                saveUserOutlet.setTitle("User Saved", for: .normal)
                DispatchQueue.main.async {
                    self.saveUserOutlet.setBackgroundImage(nil, for: .normal)
                    self.saveUserOutlet.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                }
            } else {
                saveUserOutlet.isEnabled = true
                removeUserOutlet.isHidden = true
                saveUserOutlet.setTitle("Save User", for: .normal)
                DispatchQueue.main.async {
                    let image = UIImage.createGradientImageFor(button: self.saveUserOutlet)
                    self.saveUserOutlet.backgroundColor = .clear
                    self.saveUserOutlet.setBackgroundImage(image, for: .normal)
                }
            }
        }
    }
    
    @IBAction func saveUserAction(_ sender: Any) {
        isSaved = true
        if let delegate = delegate {
            delegate.saveUser(user!)
        }
    }
    
    @IBAction func removeUserAction(_ sender: Any) {
        isSaved = false
        if let delegate = delegate{
            delegate.removeUser(user!)
        }
    }
}

extension DetailViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: pin, reuseIdentifier: "pinId")
        annotationView.image = #imageLiteral(resourceName: "Vector")
        return annotationView
    }
}
