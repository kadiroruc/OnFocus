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
            view?.showMessage(text: Constants.ValidationMessages.invalidEmail, type: .error, nil)
            return
        }
        if password == "" {
            view?.showMessage(text: Constants.ValidationMessages.invalidPassword, type: .error, nil)
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
                    self.view?.showMessage(text: "We’ve sent you a verification email. Please check your inbox and also your spam/junk folder if you don’t see it.", type: .info) {
                        self.view?.navigateToLogin()
                    }
                case .failure(let error):
                    self.view?.enableSignUpButton(true)
                    self.view?.showMessage(text: error.localizedDescription, type: .error, nil)
                }
            }
        }
    }
    
    func signInTapped() {
        view?.navigateToLogin()
    }

}
    
