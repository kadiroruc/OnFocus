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
        let viewModel = SignUpViewModel(authService: authService)
        let viewController = SignUpViewController(viewModel: viewModel)
        return viewController
    }
}
