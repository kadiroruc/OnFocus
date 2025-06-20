//
//  UIViewControllerExtension.swift
//  Test
//
//  Created by Abdulkadir Oruç on 6.06.2025.
//

import UIKit

extension UIViewController {
    func showAlert(_ text: String, type: MessageType, _ isCancelEnabled: Bool? = nil, completion: (() -> Void)? = nil) {
        let title: String
        switch type {
        case .success:
            title = "Success"
        case .error:
            title = "Error"
        case .info:
            title = "Info"
        case .warning:
            title = "Warning"
        }

        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.view.tintColor = {
            switch type {
            case .success: return .systemGreen
            case .error: return .systemRed
            case .info: return .systemBlue
            case .warning: return .systemOrange
            }
        }()

        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        if let isCancelEnabled = isCancelEnabled, isCancelEnabled {
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
        }
       

        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
