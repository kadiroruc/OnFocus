//
//  TimerSession.swift
//  Test
//
//  Created by Abdulkadir Oruç on 18.05.2025.
//

import Foundation

struct SessionModel: Codable {
    let id: String
    let duration: TimeInterval // in seconds
    let timestamp: Date
}
