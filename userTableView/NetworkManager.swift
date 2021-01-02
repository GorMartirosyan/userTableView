//
//  NetworkManager.swift
//  userTableView
//
//  Created by Gor on 12/31/20.
//

import UIKit

class NetworkManager {
    
    static let shared = NetworkManager()
    
    var isFetching = Bool()
    var pageNumber = 1
    
    func loadJson(completion: @escaping ([User]?) -> Void) {
        let urlString = "https://randomuser.me/api?seed=renderforest&results=20&page="
        let url = URL(string: urlString + String(pageNumber))
        if let url = url {
            isFetching = true
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error!", message: "\(String(describing: error!.localizedDescription))", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        alert.show()
                    }
                    print("Error: ", error!)
                    self.isFetching = false
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    let statusCode = httpResponse.statusCode
                    
                    if (statusCode != 200) {
                        DispatchQueue.main.async {
                            let errorMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                            let alert = UIAlertController(title: "Error! \(statusCode) ", message: errorMessage.capitalized, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            alert.show()
                        }
                        print ("dataTaskWithRequest HTTP status code:", statusCode)
                        self.isFetching = false
                        return
                    }
                }
                let decoder = JSONDecoder()
                if let data = data, let result = try? decoder.decode(Json.self, from: data) {
                    completion(result.results)
                    self.pageNumber += 1
                    self.isFetching = false
                    
                } else {
                    self.isFetching = false
                    completion(nil)
                }
            }
            task.resume()
        } else {
            self.isFetching = false
            completion(nil)
        }
    }
    
    func requestImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}

