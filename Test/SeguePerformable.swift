//
//  SeguePerformable.swift
//  Test
//
//  Created by Abdulkadir Oruç on 6.03.2025.
//

import UIKit

protocol SeguePerformable {
    func performSegue(identifier: String)
}

extension SeguePerformable where Self: UIViewController {
    func performSegue(identifier: String) {
        performSegue(withIdentifier: identifier, sender: self)
    }
}
