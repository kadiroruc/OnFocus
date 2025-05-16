//
//  UIViewExtension.swift
//  Test
//
//  Created by Abdulkadir Oruç on 9.03.2025.
//

import UIKit

extension UITextField {
    
    func setPlaceholder(color: UIColor, text: String) {
        self.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.foregroundColor: color]
        )
    }
    
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

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

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

