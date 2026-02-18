//
//  AuthService.swift
//  Test
//
//  Created by Abdulkadir Oruç on 14.05.2025.
//
import FirebaseAuth

protocol AuthServiceProtocol {
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func sendPasswordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void)
}

final class AuthService: AuthServiceProtocol {
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let user = authResult?.user, error == nil {
                
                completion(.success(()))
            } else {
                completion(.failure(error ?? NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: L10n.Auth.userCreationFailed])))
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if authResult?.user != nil, error == nil {
                // Email verification is temporarily disabled.
                // user.reload { verificationError in
                //     if user.isEmailVerified {
                //         completion(.success(()))
                //     } else {
                //         completion(.failure(verificationError ?? NSError(domain: "AuthService", code: 1, userInfo: [NSLocalizedDescriptionKey: L10n.Auth.emailNotVerified])))
                //         try? Auth.auth().signOut()
                //     }
                // }
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "AuthService", code: 2, userInfo: [NSLocalizedDescriptionKey: L10n.Auth.userNotFound])))
            }
        }
    }
    
    func sendPasswordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

}
