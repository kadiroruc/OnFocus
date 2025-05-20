//
//  SignUpBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 14.05.2025.
//

struct SignUpModuleBuilder {
    static func build() -> SignUpViewController {
        return SignUpViewController(viewModel: SignUpViewModel(authService: AuthService()))
    }
}
