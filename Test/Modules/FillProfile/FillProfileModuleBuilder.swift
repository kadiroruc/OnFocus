//
//  FillProfileModuleBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 15.05.2025.
//

import UIKit

struct FillProfileModuleBuilder {
    static func build() -> UIViewController {
        let profileService = ProfileService()
        let viewModel = FillProfileViewModel(service: profileService)
        let viewController = FillProfileViewController(viewModel: viewModel)
        return viewController
    }
}
