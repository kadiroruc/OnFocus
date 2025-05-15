//
//  SignUpViewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 14.05.2025.
//
import UIKit

protocol SignUpViewModelInterface {
    var view: SignUpViewInterface? { get set }
    
    func signUpTapped(email: String, password: String)
    func signInTapped()
    func rememberMeTapped(isSelected: Bool)
}

final class SignUpViewModel {
    
    weak var view: SignUpViewInterface?
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
}

extension SignUpViewModel: SignUpViewModelInterface {
    
    func signUpTapped(email: String, password: String) {
        if email == "" || !email.contains("@") {
            view?.showError(message: Constants.ValidationMessages.invalidEmail)
            return
        }
        if password == "" {
            view?.showError(message: Constants.ValidationMessages.invalidPassword)
            return
        }
        
        view?.enableSignUpButton(false)
        view?.showLoading(true)
        
        authService.signUp(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.view?.showLoading(false)

                switch result {
                case .success:
                    self.view?.navigateToFillProfile()
                case .failure(let error):
                    self.view?.enableSignUpButton(true)
                    self.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    func signInTapped() {
        view?.navigateToLogin()
    }
    
    func rememberMeTapped(isSelected: Bool) {
        // Handle remember me action here
        // For example, save the selection to UserDefaults or perform any other action
        
    }
}
    
