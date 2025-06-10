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

    
    
}

final class ProfileService {
    
    private let db = Firestore.firestore()
    private let networkManager: NetworkManaging?
    
    //MARK: - Init
    init(networkManager: NetworkManaging? = nil) {
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
        
        var userData: [String: Any] = [
            "name": name,
            "nickname": nickname
        ]
        
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            // Resmi API üzerinden yükle
            guard let networkManager = networkManager else { return }
            networkManager.upload(ProfileEndpoint.uploadImage(data: imageData), decodeTo: ProfileImageResponse.self) { [weak self] result in
                switch result {
                case .success(let response):
                    // API’den dönen URL'yi Firestore’a kaydet
                    userData["profileImageURL"] = response.data.url
                    self?.saveToFirestore(userId: userId, data: userData, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
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
        
        db.collection("users").document(userId).getDocument { document, error in
            
            if let document = document, document.exists {
                let nickname = document.get("nickname") as? String ?? ""
                let profileImageUrl = document.get("profileImageURL") as? String
                let averageWorkTime = document.get("averageDailyWorkTime") as? Double
        
                let profileModel = ProfileModel(nickname: nickname, averageWorkTime: averageWorkTime, currentStreakCount: 0, profileImageURL: profileImageUrl)
                
                completion(.success(profileModel))
                
            } else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Profile data could not be fetched."])))
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
            
            // Diğer alanları boş veya varsayılan bırakarak ProfileModel oluşturuyoruz
            let profileModel = ProfileModel(id: document.documentID,
                                            nickname: nickname,
                                            averageWorkTime: nil,
                                            currentStreakCount: nil,
                                            profileImageURL: profileImageURL)
            
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
    
}
    

