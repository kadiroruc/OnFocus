//
//  LoginBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 15.05.2025.
//

import UIKit

struct LoginModuleBuilder {
    static func build() -> UIViewController {
        return LoginViewController(viewModel: LoginViewModel(authService: AuthService()))
    }
}
