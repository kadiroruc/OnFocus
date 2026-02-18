//
//  VersionService.swift
//  OnFocus
//
//  Created by Abdulkadir Oruç on 17.07.2025.
//

import Foundation
import FirebaseFirestore


protocol VersionServiceProtocol {
    func checkAppVersion(completion: @escaping (Result<Bool, Error>) -> Void)
}

final class VersionService: VersionServiceProtocol {
    
    private let db = Firestore.firestore()
    
    func checkAppVersion(completion: @escaping (Result<Bool, Error>) -> Void) {
        // Mevcut sürüm
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let db = Firestore.firestore()
        
        // Firestore'dan sürüm bilgisini al
        db.collection("app_versions").document("version_info").getDocument { (document, error) in
            if let error = error {
                // Hata oluşursa closure ile hata döndür
                completion(.failure(error))
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                let minimumVersion = data?["minimum_version"] as? String
                let appStoreURL = data?["app_store_url"] as? String

                // Mevcut sürüm ile minimum sürümü karşılaştır
                if let minimumVersion = minimumVersion, let currentVersion = currentVersion, currentVersion < minimumVersion {
                    // Güncelleme yapılması gerektiğinde closure ile success döndür
                    
                    completion(.success(true))  // Zorunlu güncelleme gerektiği için true döndür
                } else {
                    completion(.success(false))  // Güncelleme gerekmiyor
                }
            } else {
                // Eğer belge bulunamazsa hata döndür
                let error = NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: L10n.Errors.versionInfoNotFound])
                completion(.failure(error))
            }
        }
    }
}


