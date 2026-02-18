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
    func forgotPasswordTapped(email: String)

}

final class LoginViewModel{
    weak var view: LoginViewInterface?
    private let authService: AuthServiceProtocol
    private let presenceService: PresenceServiceProtocol
    private let profileService: ProfileServiceProtocol
    
    init(authService: AuthServiceProtocol, presenceService: PresenceServiceProtocol, profileService: ProfileServiceProtocol) {
        self.authService = authService
        self.presenceService = presenceService
        self.profileService = profileService
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
                    self.profileService.didUserFillProfile { result in
                        
                        switch result {
                        case .success(let filled):
                            if filled {
                                self.view?.navigateToHome()
                            } else {
                                self.view?.navigateToFillProfile()
                            }
                        case .failure(let error):
                            self.view?.showError(message: error.localizedDescription)
                        }
                    }
                    self.presenceService.setUserStatus(online: true)
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

    func forgotPasswordTapped(email: String) {
        if email == "" || !email.contains("@") {
            view?.showError(message: Constants.ValidationMessages.invalidEmail)
            return
        }

        view?.enableLoginButton(false)
        view?.showLoading(true)

        authService.sendPasswordReset(email: email) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.view?.showLoading(false)
                self.view?.enableLoginButton(true)
                switch result {
                case .success:
                    self.view?.showMessage(message: L10n.Login.resetEmailSent)
                case .failure(let error):
                    self.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }

    
}
