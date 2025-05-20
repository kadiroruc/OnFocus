//
//  ProfileModuleBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 17.05.2025.
//

struct ProfileModuleBuilder {
    static func build() -> ProfileViewController {
        return ProfileViewController(viewModel: ProfileViewModel(profileService: ProfileService(networkManager: AFNetworkManager())))
    }
}
        
