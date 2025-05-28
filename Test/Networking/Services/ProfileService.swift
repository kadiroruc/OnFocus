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
    func saveProfile(name: String,
                     nickname: String,
                     image: UIImage?,
                     completion: @escaping (Result<Void, Error>) -> Void)

    func isNicknameAvailable(_ nickname: String,
                             completion: @escaping (Bool) -> Void)
    
    func fetchProfile(completion: @escaping (Result<ProfileModel, Error>) -> Void)
}

final class ProfileService {
    
    private let db = Firestore.firestore()
    private let networkManager: NetworkManaging
    
    //MARK: - Init
    init(networkManager: NetworkManaging) {
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
    
    func fetchProfile(completion: @escaping (Result<ProfileModel, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        print("asfa")
        db.collection("users").document(userId).getDocument { document, error in
            
            if let document = document, document.exists {
                let nickname = document.get("nickname") as? String ?? ""
                let profileImageUrl = document.get("profileImageURL") as? String
        
                let profileModel = ProfileModel(nickname: nickname, averageWorkTime: "", currentStreakCount: "", profileImageUrl: profileImageUrl)
                
                completion(.success(profileModel))
                
            } else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Profile data could not be fetched."])))
            }

        }
        
    }
}
    

