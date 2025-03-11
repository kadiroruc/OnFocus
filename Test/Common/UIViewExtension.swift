//
//  UIViewExtension.swift
//  Test
//
//  Created by Abdulkadir Oruç on 9.03.2025.
//

import UIKit

extension UITextField {
    func setBottomBorder(color: UIColor, height: CGFloat = 1.0) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.borderStyle = .none
        self.layer.addSublayer(border)
    }
    
    func setPlaceholder(color: UIColor, text: String) {
        self.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.foregroundColor: color]
        )
    }
}

