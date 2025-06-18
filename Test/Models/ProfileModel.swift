//
//  ProfileModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 27.05.2025.
//

import UIKit
import FirebaseFirestore

struct ProfileModel: Codable, Identifiable {
    @DocumentID var id: String?
    var nickname: String
    var totalWorkTime: Int?
    var currentStreakCount: Int?
    //let streakRawDates: [Date]
    var profileImageURL: String?
    var status: String?
    var streakDays: [String]?
}

extension ProfileModel {
    var totalWorkTimeFormatted: String {
        guard let totalWorkTime = totalWorkTime else {
            return "0h 0m"
        }
        let hours = totalWorkTime / 3600
        let minutes = (totalWorkTime % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

