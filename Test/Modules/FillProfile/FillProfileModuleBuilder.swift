//
//  FillProfileModuleBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 15.05.2025.
//

import UIKit

struct FillProfileModuleBuilder {
    static func build() -> UIViewController {
        return FillProfileViewController(viewModel: FillProfileViewModel(service: ProfileService(networkManager: AFNetworkManager())))
    }
}
