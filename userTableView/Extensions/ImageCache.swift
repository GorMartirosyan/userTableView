//
//  ImageCache.swift
//  userTableView
//
//  Created by Gor on 12/31/20.
//

import UIKit

class ImageCache {
    
    enum Notification {
        static let url = "url"
        static let image = "image"
        static let name = NSNotification.Name("ImageLoaded")
    }
    static let shared = ImageCache()
    
    private var cache = [URL: UIImage]()
    
    func image(for url: URL) -> UIImage? {
        if let image = cache[url] {
            return image
        }
        NetworkManager.shared.requestImage(for: url) { image in
            var userInfo: [String: Any] = [Notification.url: url]
            if let image = image {
                self.cache[url] = image
                userInfo[Notification.image] = image
            }
            NotificationCenter.default.post(name: Notification.name, object: nil, userInfo: userInfo)
        }
        return nil
    }
}
