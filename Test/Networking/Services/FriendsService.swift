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
    
    func cancelFriendRequest(from senderId: String,
                             to receiverId: String,
                             completion: @escaping (Result<Void, Error>) -> Void)
    
    func acceptFriendRequest(from senderId: String,
                             to receiverId: String,
                             completion: @escaping (Result<Void, Error>) -> Void)
    
    func rejectFriendRequest(from senderId: String,
                             to receiverId: String,
                             completion: @escaping (Result<Void, Error>) -> Void)
    
    func fetchFriends(for userId: String,
                      completion: @escaping (Result<[ProfileModel], Error>) -> Void)
    
    func fetchOnlineUserCount(completion: @escaping (Result<Int, Error>) -> Void)
    
    
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
    
    func cancelFriendRequest(from user1Id: String, to user2Id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let friendshipsRef = db.collection("friendships")
        
        let statusFilter = Filter.orFilter([
            Filter.whereField("status", isEqualTo: Constants.Firebase.pending),
            Filter.whereField("status", isEqualTo: Constants.Firebase.accepted)
        ])
        
        let userFilter = Filter.orFilter([
            Filter.andFilter([
                Filter.whereField("user1Id", isEqualTo: user1Id),
                Filter.whereField("user2Id", isEqualTo: user2Id)
            ]),
            Filter.andFilter([
                Filter.whereField("user1Id", isEqualTo: user2Id),
                Filter.whereField("user2Id", isEqualTo: user1Id)
            ])
        ])
        
        let combinedFilter = Filter.andFilter([
            statusFilter,
            userFilter
        ])
        
        friendshipsRef
            .whereFilter(combinedFilter)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    completion(.success(())) // Zaten yoksa da başarılı kabul edilir
                    return
                }
                
                friendshipsRef.document(document.documentID).delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }


    
    func acceptFriendRequest(from senderId: String, to receiverId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let friendshipsRef = db.collection("friendships")
        
        friendshipsRef
            .whereField("user1Id", isEqualTo: senderId)
            .whereField("user2Id", isEqualTo: receiverId)
            .whereField("status", isEqualTo: Constants.Firebase.pending)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    completion(.success(())) // Zaten kabul edilmiş olabilir
                    return
                }
                
                friendshipsRef.document(document.documentID).updateData([
                    "status": Constants.Firebase.accepted,
                    "updatedAt": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }
    
    func rejectFriendRequest(from senderId: String, to receiverId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let friendshipsRef = db.collection("friendships")
        
        friendshipsRef
            .whereField("user1Id", isEqualTo: senderId)
            .whereField("user2Id", isEqualTo: receiverId)
            .whereField("status", isEqualTo: Constants.Firebase.pending)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    completion(.success(())) // Zaten silinmiş olabilir
                    return
                }
                
                friendshipsRef.document(document.documentID).delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }
    
    func fetchFriends(for userId: String, completion: @escaping (Result<[ProfileModel], Error>) -> Void) {
        let db = Firestore.firestore()
        let friendshipsRef = db.collection("friendships")
        
        friendshipsRef
            .whereField("status", isEqualTo: Constants.Firebase.accepted)
            .whereFilter(Filter.orFilter([
                Filter.whereField("user1Id", isEqualTo: userId),
                Filter.whereField("user2Id", isEqualTo: userId)
            ]))
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                // Tüm arkadaş ID'lerini topla
                let friendIds: [String] = documents.compactMap { doc in
                    let data = doc.data()
                    let user1 = data["user1Id"] as? String
                    let user2 = data["user2Id"] as? String
                    return user1 == userId ? user2 : user1
                }

                // Eğer hiç arkadaş yoksa hemen dön
                guard !friendIds.isEmpty else {
                    completion(.success([]))
                    return
                }
                
                print(friendIds)

                // ID'leri 10'luk gruplara böl (Firestore 'in' sorgusu limiti)
                let chunks = friendIds.chunked(into: 10)
                var allProfiles: [ProfileModel] = []
                let group = DispatchGroup()
                var fetchError: Error?

                for chunk in chunks {
                    group.enter()
                    db.collection("users")
                        .whereField(FieldPath.documentID(), in: chunk)
                        .getDocuments { snapshot, error in
                            if let error = error {
                                fetchError = error
                            } else {
                                let models = snapshot?.documents.compactMap { doc -> ProfileModel? in
                                    let data = doc.data()
                                    let profileImageURL = data["profileImageURL"] as? String
                                    let status = data["status"] as? String

                                    return ProfileModel(id: doc.documentID,
                                                        nickname: "",
                                                        totalWorkTime: nil,
                                                        currentStreakCount: nil,
                                                        profileImageURL: profileImageURL, status: status)
                                } ?? []
                                allProfiles.append(contentsOf: models)
                            }
                            group.leave()
                        }
                }

                group.notify(queue: .main) {
                    if let error = fetchError {
                        completion(.failure(error))
                    } else {
                        completion(.success(allProfiles))
                    }
                }
            }
    }
    
    func fetchOnlineUserCount(completion: @escaping (Result<Int, Error>) -> Void) {
        let query = db.collection("users").whereField("status", isEqualTo: "online")
        
        query.count.getAggregation(source: .server) { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                completion(.success(Int(snapshot.count)))
            } else {
                completion(.success(0))
            }
        }
    }


}

    
    

