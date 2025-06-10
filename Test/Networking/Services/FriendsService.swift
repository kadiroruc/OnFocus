//
//  FriendsService.swift
//  Test
//
//  Created by Abdulkadir Oruç on 6.06.2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol FriendsServiceProtocol {

    func sendFriendRequest(from senderId: String,
                           to receiverId: String,
                            completion: @escaping (Result<Void, Error>) -> Void)
    
    func fetchFriendRequests(for userId: String,
                                  completion: @escaping (Result<[FriendshipModel], Error>) -> Void)
    
    func checkFriendshipStatus(between user1Id: String,
                               and user2Id: String,
                               completion: @escaping (Result<String?, Error>) -> Void)
    
    
}

final class FriendsService  {
    private let db = Firestore.firestore()
    
}

extension FriendsService: FriendsServiceProtocol {
    
    func checkFriendshipStatus(between user1Id: String, and user2Id: String, completion: @escaping (Result<String?, Error>) -> Void) {
        let db = Firestore.firestore()
        let friendshipsRef = db.collection("friendships")
        
        friendshipsRef
            .whereField("user1Id", in: [user1Id, user2Id])
            .whereField("user2Id", in: [user1Id, user2Id])
            .getDocuments { snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success(nil)) //there are no friendships
                    return
                }
                
                for doc in documents {
                    let data = doc.data()
                    let u1 = data["user1Id"] as? String
                    let u2 = data["user2Id"] as? String
                    
                    if (u1 == user1Id && u2 == user2Id) || (u1 == user2Id && u2 == user1Id) {
                        let status = data["status"] as? String
                        completion(.success(status)) // "pending", "accepted" vs.
                        return
                    }
                }
                
                completion(.success(nil)) // eşleşme yok
            }
    }
    
    func sendFriendRequest(from senderId: String, to receiverId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let friendshipsRef = db.collection("friendships")
        
        // Aynı kullanıcılar arasında zaten bir kayıt var mı?
        friendshipsRef
            .whereField("user1Id", in: [senderId, receiverId])
            .whereField("user2Id", in: [senderId, receiverId])
            .getDocuments { snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Eşleşen kayıt varsa
                if let docs = snapshot?.documents, !docs.isEmpty {
                    // Aynı arkadaşlık veya istek zaten var
                    completion(.success(()))
                    return
                }
                
                // Yeni istek oluştur
                let request = FriendshipModel(
                    user1Id: senderId,
                    user2Id: receiverId,
                    status: Constants.Firebase.pending,
                    createdAt: Date()
                )
                
                do {
                    _ = try friendshipsRef.addDocument(from: request)
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    func fetchFriendRequests(for userId: String, completion: @escaping (Result<[FriendshipModel], Error>) -> Void) {
        let db = Firestore.firestore()
        let friendshipsRef = db.collection("friendships")
        
        friendshipsRef
            .whereField("user2Id", isEqualTo: userId)
            .whereField("status", isEqualTo: Constants.Firebase.pending)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let requests = snapshot?.documents.compactMap({ doc -> FriendshipModel? in
                    try? doc.data(as: FriendshipModel.self)
                }) ?? []
                
                completion(.success(requests))
            }
    }
}

    
    

