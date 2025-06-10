//
//  LoginViewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 9.03.2025.
//

import UIKit

protocol LoginViewModelInterface {
    var view: LoginViewInterface? { get set }
    
    func loginButtonTapped(email: String, password: String)
    func signUpTapped()
    func rememberMeTapped(isSelected: Bool)

}

final class LoginViewModel{
    weak var view: LoginViewInterface?
    private let authService: AuthServiceProtocol
    private let presenceService: PresenceServiceProtocol
    
    init(authService: AuthServiceProtocol, presenceService: PresenceServiceProtocol) {
        self.authService = authService
        self.presenceService = presenceService
    }
    
    
    
}

extension LoginViewModel: LoginViewModelInterface{
    func loginButtonTapped(email: String, password: String) {
        if email == "" || !email.contains("@") {
            view?.showError(message: Constants.ValidationMessages.invalidEmail)
            return
        }
        if password == "" {
            view?.showError(message: Constants.ValidationMessages.invalidPassword)
            return
        }
        
        view?.enableLoginButton(false)
        view?.showLoading(true)
        
        authService.signIn(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.view?.showLoading(false)

                switch result {
                case .success:
                    self.presenceService.setUserStatus(online: true)
                    self.view?.navigateToHome()
                case .failure(let error):
                    self.view?.enableLoginButton(true)
                    self.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    func signUpTapped() {
        view?.navigateToSignUp()
    }
    
    func rememberMeTapped(isSelected: Bool) {
        // Handle remember me action
        
    }

    
}
