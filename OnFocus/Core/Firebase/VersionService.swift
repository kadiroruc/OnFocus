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
    private let localStore: OfflineStoreProtocol

    init(localStore: OfflineStoreProtocol) {
        self.localStore = localStore
    }
    
    func checkAppVersion(completion: @escaping (Result<Bool, Error>) -> Void) {
        // Mevcut sürüm
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let db = Firestore.firestore()
        
        // Firestore'dan sürüm bilgisini al
        db.collection("app_versions").document("version_info").getDocument { (document, error) in
            if let error = error {
                if let cached: AppVersionCache = self.localStore.fetch(id: "version_info", type: .appVersion),
                   let currentVersion = currentVersion {
                    completion(.success(currentVersion < cached.minimumVersion))
                } else {
                    completion(.failure(error))
                }
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                let minimumVersion = data?["minimum_version"] as? String
                let appStoreURL = data?["app_store_url"] as? String

                if let minimumVersion, let appStoreURL {
                    let cache = AppVersionCache(minimumVersion: minimumVersion, appStoreURL: appStoreURL)
                    self.localStore.save(entity: cache, id: "version_info", type: .appVersion, markDirty: false)
                }

                // Mevcut sürüm ile minimum sürümü karşılaştır
                if let minimumVersion = minimumVersion, let currentVersion = currentVersion, currentVersion < minimumVersion {
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            } else {
                let error = NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: L10n.Errors.versionInfoNotFound])
                completion(.failure(error))
            }
        }
    }
}


