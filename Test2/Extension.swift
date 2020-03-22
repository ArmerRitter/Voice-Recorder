//
//  Extension.swift
//  Test2
//
//  Created by Yuriy Balabin on 22.03.2020.
//  Copyright © 2020 None. All rights reserved.
//

import UIKit

extension UIView {
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor, location: [NSNumber]) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = location
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func clone() -> UIView {
        let view = UIView(frame: self.frame)
        view.backgroundColor = self.backgroundColor
        view.layer.cornerRadius = self.layer.cornerRadius
        view.clipsToBounds = true
        return view
    }
}

