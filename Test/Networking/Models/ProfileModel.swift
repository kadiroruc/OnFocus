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
    let nickname: String
    let totalWorkTime: Double?
    let currentStreakCount: Int?
    //let streakRawDates: [Date]
    let profileImageURL: String?
    let status: String?
}

