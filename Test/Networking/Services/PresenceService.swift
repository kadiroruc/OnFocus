//
//  PresenceService.swift
//  Test
//
//  Created by Abdulkadir Oruç on 10.06.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


protocol PresenceServiceProtocol {
    func setUserStatus(online: Bool)
    func observeUserStatus(userId: String, completion: @escaping (Result<Bool, Error>) -> Void)
}

final class PresenceService: PresenceServiceProtocol {
    
    private let db = Firestore.firestore()
    
    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    // MARK: - Kullanıcının durumunu güncelle (online / offline)
    func setUserStatus(online: Bool) {
        guard let userId = currentUserId else { return }
        print(userId)
        let status = online ? "online" : "offline"
        db.collection("users").document(userId).setData(["status": status], merge: true) { error in
            if let error = error {
                print("Status update failed: \(error.localizedDescription)")
            } else {
                print("Status updated to \(status)")
            }
        }

    }
    
    // MARK: - Belirli bir kullanıcının durumunu dinle
    func observeUserStatus(userId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        db.collection("users").document(userId).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data(),
                  let status = data["status"] as? String else {
                completion(.success(false))
                return
            }
            
            completion(.success(status == "online"))
        }
    }
}

