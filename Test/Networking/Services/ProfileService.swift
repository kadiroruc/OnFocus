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
}

final class ProfileService: ProfileServiceProtocol {
    
    private let db = Firestore.firestore()
    private let networkManager: NetworkManaging
    
    init(networkManager: NetworkManaging = AFNetworkManager()) {
        self.networkManager = networkManager
    }
    
    func saveProfile(name: String,
                     nickname: String,
                     image: UIImage?,
                     completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        var userData: [String: Any] = [
            "name": name,
            "nickname": nickname
        ]
        
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            // Resmi API üzerinden yükle
            networkManager.upload(ProfileEndpoint.uploadImage(data: imageData), decodeTo: UploadResponse.self) { [weak self] result in
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
