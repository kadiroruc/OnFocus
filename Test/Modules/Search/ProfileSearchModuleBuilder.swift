//
//  ProfileSearchModuleBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 6.06.2025.
//

import Foundation

struct ProfileSearchModuleBuilder {
    static func build() -> ProfileSearchViewController {
        return ProfileSearchViewController(viewModel: ProfileSearchViewModel(profileService: ProfileService(networkManager: AFNetworkManager())))
    }
}
