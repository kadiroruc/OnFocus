//
//  FillProfileMocks.swift
//  OnFocusTests
//
//  Created by Abdulkadir Oruç on 25.03.2025.
//

import XCTest
import UIKit
@testable import OnFocus

// MARK: - Mock Profile Service

class MockProfileService: ProfileServiceProtocol {
    var isNicknameAvailableCalled = false
    var isNicknameAvailableNickname: String?
    var isNicknameAvailableResult = true
    var isNicknameAvailableCompletion: ((Bool) -> Void)?
    
    var saveProfileCalled = false
    var saveProfileName: String?
    var saveProfileNickname: String?
    var saveProfileImage: UIImage?
    var saveProfileResult: Result<Void, Error> = .success(())
    var saveProfileCompletion: ((Result<Void, Error>) -> Void)?
    
    // MARK: - ProfileServiceProtocol Properties
    var currentUserId: String? = "mockUserId"
    
    // MARK: - ProfileServiceProtocol Methods
    func isNicknameAvailable(_ nickname: String, completion: @escaping (Bool) -> Void) {
        isNicknameAvailableCalled = true
        isNicknameAvailableNickname = nickname
        isNicknameAvailableCompletion = completion
        completion(isNicknameAvailableResult)
    }
    
    func saveProfile(name: String, nickname: String, image: UIImage?, completion: @escaping (Result<Void, Error>) -> Void) {
        saveProfileCalled = true
        saveProfileName = name
        saveProfileNickname = nickname
        saveProfileImage = image
        saveProfileCompletion = completion
        completion(saveProfileResult)
    }
    
    func fetchProfile(userId: String?, completion: @escaping (Result<ProfileModel, Error>) -> Void) {
        // Mock implementation - not used in FillProfile tests
        completion(.failure(NSError(domain: "MockError", code: -1, userInfo: nil)))
    }
    
    func searchProfiles(matching query: String, completion: @escaping (Result<[ProfileModel], Error>) -> Void) {
        // Mock implementation - not used in FillProfile tests
        completion(.success([]))
    }
    
    func fetchRequestProfileFor(userId: String?, completion: @escaping (Result<ProfileModel, Error>) -> Void) {
        // Mock implementation - not used in FillProfile tests
        completion(.failure(NSError(domain: "MockError", code: -1, userInfo: nil)))
    }
    
    func updateProfileImage(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        // Mock implementation - not used in FillProfile tests
        completion(.success(()))
    }
    
    func updateStreakDay(completion: @escaping (Result<Void, Error>) -> Void) {
        // Mock implementation - not used in FillProfile tests
        completion(.success(()))
    }
    
    func didUserFillProfile(completion: @escaping (Result<Bool, Error>) -> Void) {
        // Mock implementation - not used in FillProfile tests
        completion(.success(false))
    }
    
    func deleteProfile(completion: @escaping (Result<Void, Error>) -> Void) {
        // Mock implementation - not used in FillProfile tests
        completion(.success(()))
    }
    
    func deleteStatisticsAndFriendships(completion: @escaping (Result<Void, Error>) -> Void) {
        // Mock implementation - not used in FillProfile tests
        completion(.success(()))
    }
}

// MARK: - Mock Presence Service

class MockPresenceService: PresenceServiceProtocol {
    var setUserStatusCalled = false
    var setUserStatusOnline = false
    
    func setUserStatus(online: Bool) {
        setUserStatusCalled = true
        setUserStatusOnline = online
    }
    
    func observeUserStatus(userId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Mock implementation - not used in FillProfile tests
        completion(.success(false))
    }
}

// MARK: - Mock Fill Profile View

class MockFillProfileView: FillProfileViewInterface {
    var navigateToHomeCalled = false
    var showErrorCalled = false
    var showErrorMessage: String?
    var setProfileImageCalled = false
    var setProfileImageImage: UIImage?
    var showLoadingCalled = false
    var showLoadingIsLoading = false
    var enableStartButtonCalled = false
    var enableStartButtonIsEnabled = false
    var setNicknameNotAvailableCalled = false
    
    func navigateToHome() {
        navigateToHomeCalled = true
    }
    
    func showError(message: String) {
        showErrorCalled = true
        showErrorMessage = message
    }
    
    func setProfileImage(_ image: UIImage) {
        setProfileImageCalled = true
        setProfileImageImage = image
    }
    
    func showLoading(_ isLoading: Bool) {
        showLoadingCalled = true
        showLoadingIsLoading = isLoading
    }
    
    func enableStartButton(_ isEnabled: Bool) {
        enableStartButtonCalled = true
        enableStartButtonIsEnabled = isEnabled
    }
    
    func setNicknameNotAvailable() {
        setNicknameNotAvailableCalled = true
    }
}

// MARK: - Mock Fill Profile View Model

class MockFillProfileViewModel: FillProfileViewModelInterface, Equatable {
    weak var view: FillProfileViewInterface?
    
    var startButtonTappedCalled = false
    var startButtonTappedName: String?
    var startButtonTappedNickname: String?
    
    var setSelectedImageCalled = false
    var setSelectedImageImage: UIImage?
    
    func startButtonTapped(name: String?, nickname: String?) {
        startButtonTappedCalled = true
        startButtonTappedName = name
        startButtonTappedNickname = nickname
    }
    
    func setSelectedImage(_ image: UIImage) {
        setSelectedImageCalled = true
        setSelectedImageImage = image
    }
    
    // MARK: - Equatable
    static func == (lhs: MockFillProfileViewModel, rhs: MockFillProfileViewModel) -> Bool {
        return lhs.startButtonTappedCalled == rhs.startButtonTappedCalled &&
               lhs.startButtonTappedName == rhs.startButtonTappedName &&
               lhs.startButtonTappedNickname == rhs.startButtonTappedNickname &&
               lhs.setSelectedImageCalled == rhs.setSelectedImageCalled &&
               lhs.setSelectedImageImage == rhs.setSelectedImageImage
    }
} 