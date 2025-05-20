//
//  FillProfileModuleBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 15.05.2025.
//

struct FillProfileModuleBuilder {
    static func build() -> FillProfileViewController {
        return FillProfileViewController(viewModel: FillProfileViewModel(service: ProfileService(networkManager: AFNetworkManager())))
    }
}
