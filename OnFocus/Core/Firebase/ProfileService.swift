//
//  ProfileService.swift
//  Test
//
//  Created by Abdulkadir Oruç on 15.05.2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol ProfileServiceProtocol {
    
    var currentUserId: String? { get }
    
    func saveProfile(name: String,
                     nickname: String,
                     image: UIImage?,
                     completion: @escaping (Result<Void, Error>) -> Void)

    func isNicknameAvailable(_ nickname: String,
                             completion: @escaping (Bool) -> Void)
    
    func fetchProfile(userId: String?, completion: @escaping (Result<ProfileModel, Error>) -> Void)
    
    func searchProfiles(matching query: String,
                        completion: @escaping (Result<[ProfileModel], Error>) -> Void)
    
    func fetchRequestProfileFor(userId: String?,
                                completion: @escaping (Result<ProfileModel, Error>) -> Void)
    
    func updateProfileImage(_ image: UIImage,
                            completion: @escaping (Result<Void, Error>) -> Void)
    
    func updateStreakDay(completion: @escaping (Result<Void, Error>) -> Void)
    
    func didUserFillProfile(completion: @escaping (Result<Bool, Error>) -> Void)
    
    func deleteProfile(completion: @escaping (Result<Void, Error>) -> Void)
    
    func deleteStatisticsAndFriendships(completion: @escaping (Result<Void, Error>) -> Void)

    
    
}

final class ProfileService {
    
    private let db = Firestore.firestore()
    private let networkManager: NetworkManager?
    private let localStore: OfflineStoreProtocol
    
    //MARK: - Init
    init(networkManager: NetworkManager, localStore: OfflineStoreProtocol) {
        self.networkManager = networkManager
        self.localStore = localStore
    }
    
    private func saveToFirestore(userId: String,
                                 data: [String: Any],
                                 completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("users").document(userId).setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func deleteCollection(collectionRef: CollectionReference, batch: WriteBatch) {
        collectionRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            for document in documents {
                batch.deleteDocument(document.reference)
            }
        }
    }
}

extension ProfileService: ProfileServiceProtocol {
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    func saveProfile(name: String, nickname: String, image: UIImage?, completion: @escaping (Result<Void, Error>) -> Void) {
        saveProfileInternal(name: name, nickname: nickname, image: image, shouldEnqueueOnFailure: true, completion: completion)
    }
    
    func saveProfileInternal(name: String, nickname: String, image: UIImage?, shouldEnqueueOnFailure: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: Constants.ValidationMessages.notLoggedIn])))
            return
        }

        let profile = ProfileModel(id: userId,
                                   nickname: nickname,
                                   totalWorkTime: nil,
                                   currentStreakCount: nil,
                                   profileImageURL: nil,
                                   status: nil,
                                   streakDays: nil)
        localStore.save(entity: profile, id: userId, type: .profile, markDirty: true)

        let userData: [String: Any] = [
            "name": name,
            "nickname": nickname
        ]

        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            guard let networkManager = networkManager else { return }
            let baseUserData = userData

            Task {
                do {
                    let endpoint = ImageUploadEndpoint.uploadImage(data: imageData)
                    let response = try await networkManager.sendRequest(endpoint, responseType: ProfileImageResponse.self)
                    var updatedUserData = baseUserData
                    updatedUserData["profileImageURL"] = response.data.url
                    saveToFirestore(userId: userId, data: updatedUserData) { result in
                        switch result {
                        case .success:
                            if var cached: ProfileModel = self.localStore.fetch(id: userId, type: .profile) {
                                cached.profileImageURL = response.data.url
                                self.localStore.save(entity: cached, id: userId, type: .profile, markDirty: false)
                            }
                            self.localStore.markClean(id: userId, type: .profile)
                            completion(.success(()))
                        case .failure(let error):
                            if shouldEnqueueOnFailure {
                                let payload = ProfileUpsertPayload(userId: userId, name: name, nickname: nickname, profileImageBase64: imageData.base64EncodedString())
                                let payloadData = try? JSONEncoder().encode(payload)
                                self.localStore.enqueue(operation: .profileUpsert, entityType: .profile, entityId: userId, payload: payloadData)
                                completion(.success(()))
                            } else {
                                completion(.failure(error))
                            }
                        }
                    }
                } catch {
                    if shouldEnqueueOnFailure {
                        let payload = ProfileUpsertPayload(userId: userId, name: name, nickname: nickname, profileImageBase64: imageData.base64EncodedString())
                        let payloadData = try? JSONEncoder().encode(payload)
                        self.localStore.enqueue(operation: .profileUpsert, entityType: .profile, entityId: userId, payload: payloadData)
                        completion(.success(()))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        } else {
            saveToFirestore(userId: userId, data: userData) { result in
                switch result {
                case .success:
                    self.localStore.markClean(id: userId, type: .profile)
                    completion(.success(()))
                case .failure(let error):
                    if shouldEnqueueOnFailure {
                        let payload = ProfileUpsertPayload(userId: userId, name: name, nickname: nickname, profileImageBase64: nil)
                        let payloadData = try? JSONEncoder().encode(payload)
                        self.localStore.enqueue(operation: .profileUpsert, entityType: .profile, entityId: userId, payload: payloadData)
                        completion(.success(()))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    func isNicknameAvailable(_ nickname: String, completion: @escaping (Bool) -> Void) {
        db.collection("users")
            .whereField("nickname", isEqualTo: nickname)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking nickname availability: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                // Nickname kullanılmamışsa snapshot boş olur
                let isAvailable = snapshot?.documents.isEmpty ?? true
                completion(isAvailable)
            }
    }
    
    func fetchProfile(userId: String?, completion: @escaping (Result<ProfileModel, Error>) -> Void) {
        guard let userId = userId else { return }

        let ref = db.collection("users").document(userId)

        ref.getDocument { document, error in
            if let error = error {
                if let cached: ProfileModel = self.localStore.fetch(id: userId, type: .profile) {
                    completion(.success(cached))
                } else {
                    completion(.failure(error))
                }
                return
            }

            guard let document = document else {
                completion(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: L10n.Errors.documentNotFound])))
                return
            }

            do {
                let profile = try document.data(as: ProfileModel.self)
                if let id = profile.id {
                    self.localStore.save(entity: profile, id: id, type: .profile, markDirty: false)
                }
                completion(.success(profile))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchRequestProfileFor(userId: String?, completion: @escaping (Result<ProfileModel, Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(NSError(domain: "InvalidUserId", code: -1, userInfo: [NSLocalizedDescriptionKey: L10n.Errors.userIdNil])))
            return
        }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                if let cached: ProfileModel = self.localStore.fetch(id: userId, type: .profile) {
                    completion(.success(cached))
                } else {
                    completion(.failure(error))
                }
                return
            }

            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: L10n.Errors.profileDataNotFound])))
                return
            }

            let nickname = document.get("nickname") as? String ?? ""
            let profileImageURL = document.get("profileImageURL") as? String
            let status = document.get("status") as? String

            // Diğer alanları boş veya varsayılan bırakarak ProfileModel oluşturuyoruz
            let profileModel = ProfileModel(id: document.documentID,
                                            nickname: nickname,
                                            totalWorkTime: nil,
                                            currentStreakCount: nil,
                                            profileImageURL: profileImageURL,
                                            status: status)

            if let id = profileModel.id {
                self.localStore.save(entity: profileModel, id: id, type: .profile, markDirty: false)
            }

            completion(.success(profileModel))
        }
    }
    
    func searchProfiles(matching query: String, completion: @escaping (Result<[ProfileModel], Error>) -> Void) {
        db.collection("users")
            .whereField("nickname", isGreaterThanOrEqualTo: query)
            .whereField("nickname", isLessThan: query + "\u{f8ff}")
            .getDocuments { snapshot, error in
                if let error = error {
                    let cached: [ProfileModel] = self.localStore.fetchAll(type: .profile)
                    let filtered = cached.filter { ($0.nickname ?? "").lowercased().hasPrefix(query.lowercased()) }
                    if !filtered.isEmpty {
                        completion(.success(filtered))
                    } else {
                        completion(.failure(error))
                    }
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                let profiles: [ProfileModel] = documents.compactMap { doc in
                    try? doc.data(as: ProfileModel.self)
                }

                self.localStore.saveAll(entities: profiles, type: .profile, idProvider: { $0.id ?? UUID().uuidString }, markDirty: false)
                completion(.success(profiles))
            }
    }
    
    func updateProfileImage(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        updateProfileImageInternal(image, shouldEnqueueOnFailure: true, completion: completion)
    }
    
    func updateProfileImageInternal(_ image: UIImage, shouldEnqueueOnFailure: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "AuthError",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: Constants.ValidationMessages.notLoggedIn])))
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageError",
                                        code: -2,
                                        userInfo: [NSLocalizedDescriptionKey: L10n.Errors.invalidImageData])))
            return
        }

        guard let networkManager = networkManager else {
            if shouldEnqueueOnFailure {
                let payload = ProfileImagePayload(userId: userId, imageBase64: imageData.base64EncodedString())
                let payloadData = try? JSONEncoder().encode(payload)
                localStore.enqueue(operation: .profileUpdateImage, entityType: .profile, entityId: userId, payload: payloadData)
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "NetworkError",
                                            code: -3,
                                            userInfo: [NSLocalizedDescriptionKey: L10n.Errors.networkManagerUnavailable])))
            }
            return
        }

        Task {
            do {
                let endpoint = ImageUploadEndpoint.uploadImage(data: imageData)
                let response = try await networkManager.sendRequest(endpoint, responseType: ProfileImageResponse.self)
                let imageURL = response.data.url
                saveToFirestore(userId: userId, data: ["profileImageURL" : imageURL]) { result in
                    switch result {
                    case .success:
                        if var cached: ProfileModel = self.localStore.fetch(id: userId, type: .profile) {
                            cached.profileImageURL = imageURL
                            self.localStore.save(entity: cached, id: userId, type: .profile, markDirty: false)
                        }
                        self.localStore.markClean(id: userId, type: .profile)
                        completion(.success(()))
                    case .failure(let error):
                        if shouldEnqueueOnFailure {
                            let payload = ProfileImagePayload(userId: userId, imageBase64: imageData.base64EncodedString())
                            let payloadData = try? JSONEncoder().encode(payload)
                            self.localStore.enqueue(operation: .profileUpdateImage, entityType: .profile, entityId: userId, payload: payloadData)
                            completion(.success(()))
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
            } catch {
                if shouldEnqueueOnFailure {
                    let payload = ProfileImagePayload(userId: userId, imageBase64: imageData.base64EncodedString())
                    let payloadData = try? JSONEncoder().encode(payload)
                    localStore.enqueue(operation: .profileUpdateImage, entityType: .profile, entityId: userId, payload: payloadData)
                    completion(.success(()))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    func updateStreakDay(completion: @escaping (Result<Void, Error>) -> Void) {
        updateStreakDayInternal(shouldEnqueueOnFailure: true, dayString: nil, completion: completion)
    }

    func updateStreakDayInternal(shouldEnqueueOnFailure: Bool, dayString: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = currentUserId else {
            let error = NSError(domain: "NoAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: L10n.Errors.userNotAuthenticated])
            completion(.failure(error))
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let resolvedDayString = dayString ?? formatter.string(from: Date())

        if var cached: ProfileModel = localStore.fetch(id: userId, type: .profile) {
            var streakDays = cached.streakDays ?? []
            if !streakDays.contains(resolvedDayString) {
                streakDays.append(resolvedDayString)
            }
            cached.streakDays = streakDays
            localStore.save(entity: cached, id: userId, type: .profile, markDirty: true)
        }

        let userRef = db.collection("users").document(userId)
        userRef.updateData([
            "streakDays": FieldValue.arrayUnion([resolvedDayString])
        ]) { error in
            if let error = error {
                if shouldEnqueueOnFailure {
                    let payload = ProfileStreakPayload(userId: userId, dayString: resolvedDayString)
                    let payloadData = try? JSONEncoder().encode(payload)
                    self.localStore.enqueue(operation: .profileUpdateStreak, entityType: .profile, entityId: userId, payload: payloadData)
                    completion(.success(()))
                } else {
                    completion(.failure(error))
                }
            } else {
                self.localStore.markClean(id: userId, type: .profile)
                completion(.success(()))
            }
        }
    }
    
    func didUserFillProfile(completion: @escaping (Result<Bool, Error>) -> Void){
        guard let userId = currentUserId else { return }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(error ?? NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: L10n.Errors.documentNotFound])))
                return
            }
            
            // Profil verilerini kontrol et
            if document.get("name") is String{
                completion(.success((true)))
            } else {
                completion(.success(false))
            }
        }

    }
    
    func deleteProfile(completion: @escaping (Result<Void, Error>) -> Void) {
        deleteProfileInternal(shouldEnqueueOnFailure: true, completion: completion)
    }

    func deleteProfileInternal(shouldEnqueueOnFailure: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "AuthError",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: Constants.ValidationMessages.notLoggedIn])))
            return
        }

        localStore.markDeleted(id: userId, type: .profile)

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        let batch = db.batch()

        // Delete the user document from 'users' collection
        batch.deleteDocument(userRef)

        // Delete the 'friendships' collection documents where userId is involved as user1Id or user2Id
        let friendshipsRef = db.collection("friendships")
        
        // Query for friendships where the current userId is involved as either user1Id or user2Id
        let query1 = friendshipsRef.whereField("user1Id", isEqualTo: userId)
        let query2 = friendshipsRef.whereField("user2Id", isEqualTo: userId)
        
        // Perform the query for user1Id
        query1.getDocuments { (snapshot, error) in
            if let error = error {
                if shouldEnqueueOnFailure {
                    self.localStore.enqueue(operation: .profileDelete, entityType: .profile, entityId: userId, payload: nil)
                    completion(.success(()))
                } else {
                    completion(.failure(error))
                }
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            // Add delete operations for all documents matching user1Id
            for document in documents {
                batch.deleteDocument(document.reference)
            }
            
            // Perform the query for user2Id
            query2.getDocuments { (snapshot, error) in
                if let error = error {
                    if shouldEnqueueOnFailure {
                        self.localStore.enqueue(operation: .profileDelete, entityType: .profile, entityId: userId, payload: nil)
                        completion(.success(()))
                    } else {
                        completion(.failure(error))
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                // Add delete operations for all documents matching user2Id
                for document in documents {
                    batch.deleteDocument(document.reference)
                }
                
                // Commit the batch operation after processing all documents
                batch.commit { error in
                    if let error = error {
                        if shouldEnqueueOnFailure {
                            self.localStore.enqueue(operation: .profileDelete, entityType: .profile, entityId: userId, payload: nil)
                            completion(.success(()))
                        } else {
                            completion(.failure(error))
                        }
                        return
                    }

                    // After successfully deleting from Firestore, now delete from Firebase Authentication
                    Auth.auth().currentUser?.delete { error in
                        if let error = error {
                            if shouldEnqueueOnFailure {
                                self.localStore.enqueue(operation: .profileDelete, entityType: .profile, entityId: userId, payload: nil)
                                completion(.success(()))
                            } else {
                                completion(.failure(error))
                            }
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }


    
    func deleteStatisticsAndFriendships(completion: @escaping (Result<Void, Error>) -> Void) {
        deleteStatisticsAndFriendshipsInternal(shouldEnqueueOnFailure: true, completion: completion)
    }

    func deleteStatisticsAndFriendshipsInternal(shouldEnqueueOnFailure: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "AuthError",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: Constants.ValidationMessages.notLoggedIn])))
            return
        }
        
        let userRef = db.collection("users").document(userId)
        
        // Set streakDays and totalWorkTime to default values
        let dataToUpdate: [String: Any] = [
            "streakDays": [],
            "totalWorkTime": 0
        ]
        
        // Start batch write operation
        let batch = db.batch()
        
        // Update user document
        batch.updateData(dataToUpdate, forDocument: userRef)
        
        // Delete 'sessions' and 'statistics' subcollections
        let sessionsRef = userRef.collection("sessions")
        let statisticsRef = userRef.collection("statistics")
        
        // Delete documents in sessions and statistics collections
        deleteCollection(collectionRef: sessionsRef, batch: batch)
        deleteCollection(collectionRef: statisticsRef, batch: batch)
        
        // Delete 'friendships' collection documents where userId is either user1Id or user2Id
        let friendshipsRef = db.collection("friendships")
        
        // Query for friendships where the current userId is involved as either user1Id or user2Id
        let query1 = friendshipsRef.whereField("user1Id", isEqualTo: userId)
        let query2 = friendshipsRef.whereField("user2Id", isEqualTo: userId)
        
        // Fetch documents matching user1Id
        query1.getDocuments { (snapshot, error) in
            if let error = error {
                if shouldEnqueueOnFailure {
                    self.localStore.enqueue(operation: .profileDeleteStatisticsAndFriendships, entityType: .profile, entityId: userId, payload: nil)
                    completion(.success(()))
                } else {
                    completion(.failure(error))
                }
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            for document in documents {
                batch.deleteDocument(document.reference)
            }
            
            // Now, fetch documents matching user2Id (after the first query is done)
            query2.getDocuments { (snapshot, error) in
                if let error = error {
                    if shouldEnqueueOnFailure {
                        self.localStore.enqueue(operation: .profileDeleteStatisticsAndFriendships, entityType: .profile, entityId: userId, payload: nil)
                        completion(.success(()))
                    } else {
                        completion(.failure(error))
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                for document in documents {
                    batch.deleteDocument(document.reference)
                }
                
                // Commit the batch operation after processing all documents
                batch.commit { error in
                    if let error = error {
                        if shouldEnqueueOnFailure {
                            self.localStore.enqueue(operation: .profileDeleteStatisticsAndFriendships, entityType: .profile, entityId: userId, payload: nil)
                            completion(.success(()))
                        } else {
                            completion(.failure(error))
                        }
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }


    
}
    

