//
//  LoginBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 15.05.2025.
//

import UIKit

struct LoginModuleBuilder {
    static func build() -> UIViewController {
        let authService = AuthService()
        let viewModel = LoginViewModel(authService: authService)
        let viewController = LoginViewController(viewModel: viewModel)
        return viewController
    }
}
