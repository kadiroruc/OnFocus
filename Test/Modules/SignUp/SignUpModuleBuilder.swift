//
//  SignUpBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 14.05.2025.
//
import UIKit

struct SignUpModuleBuilder {
    static func build() -> UIViewController {
        return SignUpViewController(viewModel: SignUpViewModel(authService: AuthService()))
    }
}
