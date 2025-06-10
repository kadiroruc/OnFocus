//
//  DIContainer.swift
//  Test
//
//  Created by Abdulkadir Oruç on 10.06.2025.
//

import Foundation

final class DIContainer {
    // MARK: - Shared Instance
    static let shared = DIContainer()

    // MARK: - Services
    lazy var authService: AuthServiceProtocol = {
        return AuthService()
    }()

    lazy var profileService: ProfileServiceProtocol = {
        return ProfileService()
    }()
    
    lazy var friendsService: FriendsServiceProtocol = {
        return FriendsService()
    }()
    
    lazy var timerService: TimerServiceProtocol = {
        return TimerService()
    }()
    
    lazy var presenceService: PresenceServiceProtocol = {
        return PresenceService()
    }()

    // MARK: - ViewModels
    func makeFillProfileViewModel() -> FillProfileViewModel {
        return FillProfileViewModel(service: profileService, presenceService: PresenceService())
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(timerService: timerService)
    }
    
//    func makeLeaderboardViewModel() -> LeaderboardViewModel {
//        return
//    }
    
    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(authService: authService, presenceService: presenceService)
    }
    
    func makeNotificationsViewModel() -> NotificationsViewModel {
        return NotificationsViewModel(friendsService: friendsService, profileService: profileService)
    }
    
    func makeProfileViewModel() -> ProfileViewModel {
        return ProfileViewModel(profileService: profileService, friendsService: friendsService, presenceService: presenceService, userId: nil)
    }

    func makeProfileSearchViewModel() -> ProfileSearchViewModel {
        return ProfileSearchViewModel(profileService: profileService)
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel()
    }
    
    func makeSignUpViewModel() -> SignUpViewModel {
        return SignUpViewModel(authService: authService)
    }
    
    func makeStatisticsViewModel() -> StatisticsViewModel {
        return StatisticsViewModel(service: timerService)
    }
    
    

    // MARK: - ViewControllers

    func makeFillProfileViewController() -> FillProfileViewController {
        return FillProfileViewController(viewModel: makeFillProfileViewModel())
    }

    func makeHomeViewController() -> HomeViewController {
        return HomeViewController(viewModel: makeHomeViewModel())
    }

//    func makeLeaderboardViewController() -> LeaderboardViewController {
//        return LeaderboardViewController(viewModel: makeLeaderboardViewModel())
//    }

    func makeLoginViewController() -> LoginViewController {
        return LoginViewController(viewModel: makeLoginViewModel())
    }

    func makeNotificationsViewController() -> NotificationsViewController {
        return NotificationsViewController(viewModel: makeNotificationsViewModel())
    }

    func makeProfileViewController(userId: String? = nil) -> ProfileViewController {
        return ProfileViewController(viewModel: ProfileViewModel(
            profileService: profileService,
            friendsService: friendsService,
            presenceService: presenceService,
            userId: userId
        ))
    }

    func makeProfileSearchViewController() -> ProfileSearchViewController {
        return ProfileSearchViewController(viewModel: makeProfileSearchViewModel())
    }

//    func makeSettingsViewController() -> SettingsViewController {
//        return SettingsViewController(viewModel: makeSettingsViewModel())
//    }

    func makeSignUpViewController() -> SignUpViewController {
        return SignUpViewController(viewModel: makeSignUpViewModel())
    }

    func makeStatisticsViewController() -> StatisticsViewController {
        return StatisticsViewController(viewModel: makeStatisticsViewModel())
    }

}

