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
    
    //MARK: - Init
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
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
        
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: Constants.ValidationMessages.notLoggedIn])))
            return
        }
        
        let userData: [String: Any] = [
            "name": name,
            "nickname": nickname
        ]
        
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            // Resmi API üzerinden yükle
            guard let networkManager = networkManager else { return }
            let baseUserData = userData
            
            Task {
                do {
                    let endpoint = ImageUploadEndpoint.uploadImage(data: imageData)
                    
                    let response = try await networkManager.sendRequest(endpoint, responseType: ProfileImageResponse.self)
                    var updatedUserData = baseUserData
                    updatedUserData["profileImageURL"] = response.data.url
                    saveToFirestore(userId: userId, data: updatedUserData, completion: completion)

                } catch {
                    completion(.failure(NSError(domain: "NetworkError",
                                        code: -2,
                                        userInfo: [NSLocalizedDescriptionKey: L10n.Errors.imageUploadFailed])))
                }
            }
            
           
        } else {
            // Resim yoksa sadece Firestore kaydı yap
            saveToFirestore(userId: userId, data: userData, completion: completion)
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
                completion(.failure(error))
                return
            }
            
            guard let document = document else {
                completion(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: L10n.Errors.documentNotFound])))
                return
            }
            
            do {
                let profile = try document.data(as: ProfileModel.self)
                
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
                completion(.failure(error))
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
            
            completion(.success(profileModel))
        }
    }
    
    func searchProfiles(matching query: String, completion: @escaping (Result<[ProfileModel], Error>) -> Void) {
        db.collection("users")
            .whereField("nickname", isGreaterThanOrEqualTo: query)
            .whereField("nickname", isLessThan: query + "\u{f8ff}")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                

                let profiles: [ProfileModel] = documents.compactMap { doc in
                    try? doc.data(as: ProfileModel.self)
                }
                
                completion(.success(profiles))
            }
    }
    
    func updateProfileImage(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        
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
            completion(.failure(NSError(domain: "NetworkError",
                                        code: -3,
                                        userInfo: [NSLocalizedDescriptionKey: L10n.Errors.networkManagerUnavailable])))
            return
        }
        
        

        // Resmi yükle
        
        Task {
            do {
                let endpoint = ImageUploadEndpoint.uploadImage(data: imageData)
                let response = try await networkManager.sendRequest(endpoint, responseType: ProfileImageResponse.self)
                saveToFirestore(userId: userId, data: ["profileImageURL" : response.data.url], completion: completion)

            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func updateStreakDay(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = currentUserId else {
            let error = NSError(domain: "NoAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: L10n.Errors.userNotAuthenticated])
            completion(.failure(error))
            return
        }

        let userRef = db.collection("users").document(userId)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())

        userRef.updateData([
            "streakDays": FieldValue.arrayUnion([todayString])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
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
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "AuthError",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: Constants.ValidationMessages.notLoggedIn])))
            return
        }

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
                completion(.failure(error))
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
                    completion(.failure(error))
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
                        completion(.failure(error))
                        return
                    }

                    // After successfully deleting from Firestore, now delete from Firebase Authentication
                    Auth.auth().currentUser?.delete { error in
                        if let error = error {
                            completion(.failure(error)) // If there's an error deleting from Auth, return that error
                        } else {
                            completion(.success(())) // If everything is successful, complete the process
                        }
                    }
                }
            }
        }
    }


    
    func deleteStatisticsAndFriendships(completion: @escaping (Result<Void, Error>) -> Void) {
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
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            for document in documents {
                batch.deleteDocument(document.reference)
            }
            
            // Now, fetch documents matching user2Id (after the first query is done)
            query2.getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                for document in documents {
                    batch.deleteDocument(document.reference)
                }
                
                // Commit the batch operation after processing all documents
                batch.commit { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }


    
}
    

