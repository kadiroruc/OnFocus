//
//  ProfileModuleBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 17.05.2025.
//

import UIKit

struct ProfileModuleBuilder {
    static func build() -> UIViewController {
        return ProfileViewController(viewModel: ProfileViewModel(profileService: ProfileService(networkManager: AFNetworkManager())))
    }
}
        
