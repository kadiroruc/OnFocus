//
//  FriendshipModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 6.06.2025.
//

import Foundation
import FirebaseFirestore

struct FriendshipModel: Codable, Identifiable {
    @DocumentID var id: String?
    let user1Id: String
    let user2Id: String
    let status: String  // "pending", "accepted", "rejected"
    let createdAt: Timestamp?
}
