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
}

final class AuthService: AuthServiceProtocol {
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let user = authResult?.user, error == nil {
                
                completion(.success(()))
            } else {
                completion(.failure(error ?? NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "The user could not be created."])))
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let user = authResult?.user, error == nil {
                user.reload { verificationError in
                    if user.isEmailVerified {
                        completion(.success(()))
                    } else {
                        completion(.failure(verificationError ?? NSError(domain: "AuthService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Your email is not verified. Please check your inbox."])))
                        try? Auth.auth().signOut()
                    }
                }
            } else {
                completion(.failure(NSError(domain: "AuthService", code: 2, userInfo: [NSLocalizedDescriptionKey: "The user could not be found."])))
            }
        }
    }

}
