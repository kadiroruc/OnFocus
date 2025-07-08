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
                                        userInfo: [NSLocalizedDescriptionKey: "Failed to upload image."])))
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
                completion(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found."])))
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
            completion(.failure(NSError(domain: "InvalidUserId", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID is nil."])))
            return
        }
        
        db.collection("users").document(userId).getDocument { document, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Profile data not found."])))
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
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid image data."])))
            return
        }
        
        guard let networkManager = networkManager else {
            completion(.failure(NSError(domain: "NetworkError",
                                        code: -3,
                                        userInfo: [NSLocalizedDescriptionKey: "Network manager not available."])))
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
            let error = NSError(domain: "NoAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
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
                completion(.failure(error ?? NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found."])))
                return
            }
            
            // Profil verilerini kontrol et
            if let name = document.get("name") as? String{
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
        
        db.collection("users").document(userId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    
}
    

