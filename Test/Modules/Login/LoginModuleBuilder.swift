//
//  LoginBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 15.05.2025.
//

struct LoginModuleBuilder {
    static func build() -> LoginViewController {
        return LoginViewController(viewModel: LoginViewModel(authService: AuthService()))
    }
}
