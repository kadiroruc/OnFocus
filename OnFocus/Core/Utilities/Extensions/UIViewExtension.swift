//
//  UIViewExtension.swift
//  Test
//
//  Created by Abdulkadir Oruç on 18.05.2025.
//

import UIKit

extension UIView{
    
    func setGradientBackground(colors: [UIColor], locations: [NSNumber]? = nil) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.frame = self.bounds

        // Önceden eklenmiş gradientLayer varsa kaldırmak iyi olur
        if let oldGradientLayer = (self.layer.sublayers?.first { $0 is CAGradientLayer }) {
            oldGradientLayer.removeFromSuperlayer()
        }

        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func allAttachedConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        var currentSuperview: UIView? = self
        while let superview = currentSuperview {
            let attached = superview.constraints.filter { $0.firstItem as? UIView == self || $0.secondItem as? UIView == self }
            constraints.append(contentsOf: attached)
            currentSuperview = superview.superview
        }
        return constraints
    }
}
