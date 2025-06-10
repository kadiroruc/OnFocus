//
//  NotificationsModuleBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 6.06.2025.
//

import Foundation

struct NotificationsModuleBuilder {
    static func build() -> NotificationsViewController {
        return NotificationsViewController(viewModel: NotificationsViewModel(friendsService: FriendsService(), profileService: ProfileService(networkManager: nil)))
    }
}
