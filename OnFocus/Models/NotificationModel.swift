//
//  NotificationModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 6.06.2025.
//
import Foundation
import FirebaseFirestore

struct NotificationModel {
    let user: ProfileModel
    let type: String
    let date: Timestamp?
}
