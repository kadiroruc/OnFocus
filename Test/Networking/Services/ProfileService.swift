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
        //        guard let userId = Auth.auth().currentUser?.uid else {
        //            completion(.failure(NSError(domain: "AuthError",
        //                                        code: -1,
        //                                        userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
        //            return
        //        }
        //
        //        db.collection("users").document(userId).getDocument { snapshot, error in
        //            if let error = error {
        //                completion(.failure(error))
        //                return
        //            }
        //
        //            guard let data = snapshot?.data(),
        //                  let nickname = data["nickname"] as? String,
        //                  let averageWorkTime = data["averageWorkTime"] as? Int,
        //                  let currentStreakCount = data["currentStreakCount"] as? Int,
        //                  let streakTimestamps = data["streakRawDates"] as? [Timestamp],
        //                  let profileImagePath = data["profileImagePath"] as? String
        //            else {
        //                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid profile data"])))
        //                return
        //            }
        //
        //            let streakRawDates: [Date] = streakTimestamps.map { $0.dateValue() }
        //
        //            // Fetch image from Firebase Storage
        //            let imageRef = self.storage.reference(withPath: profileImagePath)
        //            imageRef.getData(maxSize: 5 * 1024 * 1024) { imageData, error in
        //                if let error = error {
        //                    completion(.failure(error))
        //                    return
        //                }
        //
        //                guard let imageData = imageData,
        //                      let image = UIImage(data: imageData) else {
        //                    completion(.failure(NSError(domain: "ImageError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unable to decode image"])))
        //                    return
        //                }
        //
        //                let profile = ProfileModel(
        //                    profileImage: image,
        //                    nickname: nickname,
        //                    averageWorkTime: averageWorkTime,
        //                    currentStreakCount: currentStreakCount,
        //                    streakRawDates: streakRawDates
        //                )
        //
        //                completion(.success(profile))
        //            }
        //        }
        
    }
}
    

