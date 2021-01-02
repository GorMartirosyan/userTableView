//
//  GradientImage.swift
//  userTableView
//
//  Created by Gor on 1/2/21.
//

import UIKit

extension UIImage {
    static func createGradientImageFor(button: UIButton) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = button.layer.cornerRadius
        let colors = [UIColor(red: 43/255, green: 226/255, blue: 128/255, alpha: 1).cgColor,
                      UIColor(red: 38/255, green: 199/255, blue: 113/255, alpha: 1).cgColor]
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
