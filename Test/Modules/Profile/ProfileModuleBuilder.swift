//
//  ProfileModuleBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 17.05.2025.
//

struct ProfileModuleBuilder {
    static func build(userId: String?) -> ProfileViewController {
        if let userId = userId {
            return ProfileViewController(viewModel: ProfileViewModel(profileService: ProfileService(networkManager: AFNetworkManager()),friendsService: FriendsService(),presenceService: PresenceService(), userId: userId))
        }else{
            return ProfileViewController(viewModel: ProfileViewModel(profileService: ProfileService(networkManager: AFNetworkManager()),friendsService: FriendsService(), presenceService: PresenceService(), userId: nil))
        }

    }
}
        
