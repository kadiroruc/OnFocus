//
//  PresenceService.swift
//  Test
//
//  Created by Abdulkadir Oruç on 10.06.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase


protocol PresenceServiceProtocol {
    func setUserStatus(online: Bool)
    func observeUserStatus(userId: String, completion: @escaping (Result<Bool, Error>) -> Void)
}

final class PresenceService: PresenceServiceProtocol {
    
    private let db = Firestore.firestore()
    private let rtdb = Database.database().reference()
    private let profileService: ProfileServiceProtocol
    private var connectedHandle: DatabaseHandle?
    private var isTrackingPresence = false
    
    init(profileService: ProfileServiceProtocol) {
        self.profileService = profileService
    }
    
    private var currentUserId: String? {
        profileService.currentUserId
    }
    
    // MARK: - Kullanıcının durumunu güncelle (online / offline)
    func setUserStatus(online: Bool) {
        guard let userId = currentUserId else { return }
        let statusRef = rtdb.child("status").child(userId)
        let connectedRef = rtdb.child(".info/connected")
        
        if online {
            guard !isTrackingPresence else { return }
            isTrackingPresence = true
            connectedHandle = connectedRef.observe(.value) { snapshot in
                guard let isConnected = snapshot.value as? Bool, isConnected else { return }
                statusRef.onDisconnectSetValue([
                    "state": "offline",
                    "last_changed": ServerValue.timestamp()
                ])
                statusRef.setValue([
                    "state": "online",
                    "last_changed": ServerValue.timestamp()
                ])
            }
        } else {
            isTrackingPresence = false
            if let handle = connectedHandle {
                connectedRef.removeObserver(withHandle: handle)
                connectedHandle = nil
            }
            statusRef.setValue([
                "state": "offline",
                "last_changed": ServerValue.timestamp()
            ])
        }
    }
    
    // MARK: - Belirli bir kullanıcının durumunu dinle
    func observeUserStatus(userId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        rtdb.child("status").child(userId).observe(.value) { snapshot in
            guard let data = snapshot.value as? [String: Any],
                  let state = data["state"] as? String else {
                completion(.success(false))
                return
            }
            completion(.success(state == "online"))
        }
    }
}

