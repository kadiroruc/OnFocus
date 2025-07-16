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
    private let profileService: ProfileServiceProtocol
    
    init(profileService: ProfileServiceProtocol) {
        self.profileService = profileService
    }
    
    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    // MARK: - Kullanıcının durumunu güncelle (online / offline)
    func setUserStatus(online: Bool) {
        guard let userId = profileService.currentUserId else { return }
        
        let status = online ? "online" : "offline"
        db.collection("users").document(userId).setData(["status": status], merge: true) { error in
            
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

