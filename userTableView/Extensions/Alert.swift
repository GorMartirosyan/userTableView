//
//  Alert.swift
//  userTableView
//
//  Created by Gor on 1/2/21.
//

import UIKit

extension UIAlertController {
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(self, animated: animated, completion: completion)
        }
    }
}
