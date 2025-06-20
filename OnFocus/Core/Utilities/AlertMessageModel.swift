//
//  AlertMessageModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 6.06.2025.
//
import UIKit

struct AlertMessage {
    let text: String
    let type: MessageType
}

enum MessageType {
    case success
    case error
    case info
    case warning

    var color: UIColor {
        switch self {
        case .success: return .systemGreen
        case .error: return .systemRed
        case .info: return .systemBlue
        case .warning: return .systemOrange
        }
    }

    var icon: UIImage? {
        switch self {
        case .success: return UIImage(systemName: "checkmark.circle")
        case .error: return UIImage(systemName: "xmark.octagon")
        case .info: return UIImage(systemName: "info.circle")
        case .warning: return UIImage(systemName: "exclamationmark.triangle")
        }
    }
}


