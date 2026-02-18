//
//  FriendsService.swift
//  Test
//
//  Created by Abdulkadir Oruç on 6.06.2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

protocol FriendsServiceProtocol {

    func sendFriendRequest(from senderId: String,
                           to receiverId: String,
                            completion: @escaping (Result<Void, Error>) -> Void)
    
    func fetchFriendRequests(for userId: String,
                                  completion: @escaping (Result<[FriendshipModel], Error>) -> Void)
    
    func observeFriendRequests(for userId: String,
                               completion: @escaping (Result<[FriendshipModel], Error>) -> Void) -> ListenerRegistration
    
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
    
    func observeFriends(for userId: String,
                        completion: @escaping (Result<[ProfileModel], Error>) -> Void) -> FriendsListenerToken
    
    func observeOnlineUserCount(completion: @escaping (Result<Int, Error>) -> Void) -> ListenerRegistration
    
    
}

final class FriendsListenerToken {
    private let removeHandler: () -> Void
    
    init(removeHandler: @escaping () -> Void) {
        self.removeHandler = removeHandler
    }
    
    func remove() {
        removeHandler()
    }
}

final class RTDBListenerRegistration: NSObject, ListenerRegistration {
    private let removeHandler: () -> Void

    init(removeHandler: @escaping () -> Void) {
        self.removeHandler = removeHandler
    }

    func remove() {
        removeHandler()
    }
}

final class FriendsService  {
    private let db = Firestore.firestore()
    private let rtdb = Database.database().reference()
    
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
                let data: [String: Any] = [
                    "user1Id": senderId,
                    "user2Id": receiverId,
                    "status": "pending",
                    "createdAt": FieldValue.serverTimestamp()
                ]

                friendshipsRef.addDocument(data: data) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
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
    
    func observeFriendRequests(for userId: String,
                               completion: @escaping (Result<[FriendshipModel], Error>) -> Void) -> ListenerRegistration {
        let friendshipsRef = db.collection("friendships")
        
        return friendshipsRef
            .whereField("user2Id", isEqualTo: userId)
            .whereField("status", isEqualTo: Constants.Firebase.pending)
            .addSnapshotListener { snapshot, error in
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
                                    let nickname = data["nickname"] as? String ?? ""

                                    return ProfileModel(id: doc.documentID,
                                                        nickname: nickname,
                                                        totalWorkTime: nil,
                                                        currentStreakCount: nil,
                                                        profileImageURL: profileImageURL,
                                                        status: nil)
                                } ?? []
                                allProfiles.append(contentsOf: models)
                            }
                            group.leave()
                        }
                }

                group.notify(queue: .main) {
                    if let error = fetchError {
                        completion(.failure(error))
                        return
                    }

                    var profilesWithStatus = allProfiles
                    let statusGroup = DispatchGroup()

                    for index in profilesWithStatus.indices {
                        guard let friendId = profilesWithStatus[index].id else { continue }
                        statusGroup.enter()
                        self.rtdb.child("status").child(friendId).observeSingleEvent(of: .value) { snapshot in
                            if let data = snapshot.value as? [String: Any],
                               let state = data["state"] as? String {
                                profilesWithStatus[index].status = state
                            } else {
                                profilesWithStatus[index].status = "offline"
                            }
                            statusGroup.leave()
                        } withCancel: { _ in
                            statusGroup.leave()
                        }
                    }

                    statusGroup.notify(queue: .main) {
                        completion(.success(profilesWithStatus))
                    }
                }
            }
    }
    
    func fetchOnlineUserCount(completion: @escaping (Result<Int, Error>) -> Void) {
        let query = rtdb.child("status").queryOrdered(byChild: "state").queryEqual(toValue: "online")
        query.observeSingleEvent(of: .value) { snapshot in
            completion(.success(Int(snapshot.childrenCount)))
        } withCancel: { error in
            completion(.failure(error))
        }
    }
    
    func observeFriends(for userId: String,
                        completion: @escaping (Result<[ProfileModel], Error>) -> Void) -> FriendsListenerToken {
        let friendshipsRef = db.collection("friendships")
        
        var userListeners: [ListenerRegistration] = []
        var profilesById: [String: ProfileModel] = [:]
        var statusById: [String: String] = [:]
        var rtdbHandles: [DatabaseHandle] = []
        var rtdbRefs: [DatabaseReference] = []
        
        let friendshipsListener = friendshipsRef
            .whereField("status", isEqualTo: Constants.Firebase.accepted)
            .whereFilter(Filter.orFilter([
                Filter.whereField("user1Id", isEqualTo: userId),
                Filter.whereField("user2Id", isEqualTo: userId)
            ]))
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let documents = snapshot?.documents ?? []
                let friendIds: [String] = documents.compactMap { doc in
                    let data = doc.data()
                    let user1 = data["user1Id"] as? String
                    let user2 = data["user2Id"] as? String
                    return user1 == userId ? user2 : user1
                }
                
                userListeners.forEach { $0.remove() }
                userListeners.removeAll()
                profilesById.removeAll()
                statusById.removeAll()
                
                for (index, handle) in rtdbHandles.enumerated() {
                    let ref = rtdbRefs[index]
                    ref.removeObserver(withHandle: handle)
                }
                rtdbHandles.removeAll()
                rtdbRefs.removeAll()
                
                guard !friendIds.isEmpty else {
                    completion(.success([]))
                    return
                }
                
                for friendId in friendIds {
                    let listener = self.db.collection("users").document(friendId)
                        .addSnapshotListener { snapshot, error in
                            if let error = error {
                                completion(.failure(error))
                                return
                            }
                            
                            guard let data = snapshot?.data() else {
                                profilesById.removeValue(forKey: friendId)
                                completion(.success(friendIds.compactMap { profilesById[$0] }))
                                return
                            }
                            
                            let profileImageURL = data["profileImageURL"] as? String
                            let nickname = data["nickname"] as? String ?? ""
                            let status = statusById[friendId] ?? "offline"
                            
                            let model = ProfileModel(
                                id: friendId,
                                nickname: nickname,
                                totalWorkTime: nil,
                                currentStreakCount: nil,
                                profileImageURL: profileImageURL,
                                status: status
                            )
                            profilesById[friendId] = model
                            completion(.success(friendIds.compactMap { profilesById[$0] }))
                        }
                    userListeners.append(listener)
                    
                    let statusRef = self.rtdb.child("status").child(friendId)
                    let handle = statusRef.observe(.value) { snapshot in
                        let state = (snapshot.value as? [String: Any])?["state"] as? String ?? "offline"
                        statusById[friendId] = state
                        if var model = profilesById[friendId] {
                            model.status = state
                            profilesById[friendId] = model
                            completion(.success(friendIds.compactMap { profilesById[$0] }))
                        }
                    }
                    rtdbRefs.append(statusRef)
                    rtdbHandles.append(handle)
                }
            }
        
        return FriendsListenerToken { [weak friendshipsListener] in
            friendshipsListener?.remove()
            userListeners.forEach { $0.remove() }
            userListeners.removeAll()
            for (index, handle) in rtdbHandles.enumerated() {
                let ref = rtdbRefs[index]
                ref.removeObserver(withHandle: handle)
            }
            rtdbHandles.removeAll()
            rtdbRefs.removeAll()
        }
    }
    
    func observeOnlineUserCount(completion: @escaping (Result<Int, Error>) -> Void) -> ListenerRegistration {
        let query = rtdb.child("status").queryOrdered(byChild: "state").queryEqual(toValue: "online")
        let handle = query.observe(.value) { snapshot in
            completion(.success(Int(snapshot.childrenCount)))
        }
        return RTDBListenerRegistration { [weak query] in
            query?.removeObserver(withHandle: handle)
        }
    }


}

    
    
