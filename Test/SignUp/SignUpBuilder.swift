//
//  SignUpBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 14.05.2025.
//
import UIKit

struct SignUpModuleBuilder {
    static func build() -> UIViewController {
        let authService = AuthService()
        let viewModel = SignUpViewModel(authService: authService)
        let viewController = SignUpViewController(viewModel: viewModel)
        return viewController
    }
}
