//
//  FillProfileViewModelTests.swift
//  OnFocusTests
//
//  Created by Abdulkadir Oruç on 25.03.2025.
//

import XCTest
import UIKit
@testable import OnFocus

final class FillProfileViewModelTests: XCTestCase {
    
    var sut: FillProfileViewModel!
    var mockProfileService: MockProfileService!
    var mockPresenceService: MockPresenceService!
    var mockView: MockFillProfileView!
    
    override func setUp() {
        super.setUp()
        mockProfileService = MockProfileService()
        mockPresenceService = MockPresenceService()
        mockView = MockFillProfileView()
        
        sut = FillProfileViewModel(
            profileService: mockProfileService,
            presenceService: mockPresenceService
        )
        sut.view = mockView
    }
    
    override func tearDown() {
        sut = nil
        mockProfileService = nil
        mockPresenceService = nil
        mockView = nil
        super.tearDown()
    }
    
    // MARK: - setSelectedImage Tests
    
    func test_setSelectedImage_shouldUpdateViewWithImage() {
        // Given
        let testImage = UIImage()
        
        // When
        sut.setSelectedImage(testImage)
        
        // Then
        XCTAssertTrue(mockView.setProfileImageCalled)
        XCTAssertEqual(mockView.setProfileImageImage, testImage)
    }
    
    // MARK: - startButtonTapped Tests
    
    func test_startButtonTapped_withEmptyName_shouldShowError() {
        // Given
        let name = ""
        let nickname = "testNickname"
        
        // When
        sut.startButtonTapped(name: name, nickname: nickname)
        
        // Then
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.showErrorMessage, Constants.ValidationMessages.fillAllFields)
        XCTAssertFalse(mockProfileService.isNicknameAvailableCalled)
    }
    
    func test_startButtonTapped_withNilName_shouldShowError() {
        // Given
        let name: String? = nil
        let nickname = "testNickname"
        
        // When
        sut.startButtonTapped(name: name, nickname: nickname)
        
        // Then
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.showErrorMessage, Constants.ValidationMessages.fillAllFields)
        XCTAssertFalse(mockProfileService.isNicknameAvailableCalled)
    }
    
    func test_startButtonTapped_withEmptyNickname_shouldShowError() {
        // Given
        let name = "Test User"
        let nickname = ""
        
        // When
        sut.startButtonTapped(name: name, nickname: nickname)
        
        // Then
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.showErrorMessage, Constants.ValidationMessages.fillAllFields)
        XCTAssertFalse(mockProfileService.isNicknameAvailableCalled)
    }
    
    func test_startButtonTapped_withNilNickname_shouldShowError() {
        // Given
        let name = "Test User"
        let nickname: String? = nil
        
        // When
        sut.startButtonTapped(name: name, nickname: nickname)
        
        // Then
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.showErrorMessage, Constants.ValidationMessages.fillAllFields)
        XCTAssertFalse(mockProfileService.isNicknameAvailableCalled)
    }
    
    func test_startButtonTapped_withValidInputs_shouldCheckNicknameAvailability() {
        // Given
        let name = "Test User"
        let nickname = "testNickname"
        mockProfileService.isNicknameAvailableResult = true
        
        // When
        sut.startButtonTapped(name: name, nickname: nickname)
        
        // Then
        XCTAssertTrue(mockProfileService.isNicknameAvailableCalled)
        XCTAssertEqual(mockProfileService.isNicknameAvailableNickname, nickname)
        XCTAssertTrue(mockView.enableStartButtonCalled)
        XCTAssertEqual(mockView.enableStartButtonIsEnabled, false)
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertEqual(mockView.showLoadingIsLoading, true)
    }
    
    func test_startButtonTapped_whenNicknameNotAvailable_shouldShowError() {
        // Given
        let name = "Test User"
        let nickname = "testNickname"
        mockProfileService.isNicknameAvailableResult = false
        
        // When
        sut.startButtonTapped(name: name, nickname: nickname)
        
        // Then
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.showErrorMessage, Constants.ValidationMessages.nicknameTaken)
        XCTAssertTrue(mockView.setNicknameNotAvailableCalled)
        XCTAssertTrue(mockView.enableStartButtonCalled)
        XCTAssertEqual(mockView.enableStartButtonIsEnabled, true)
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertEqual(mockView.showLoadingIsLoading, false)
    }
    
    func test_startButtonTapped_whenProfileSaveSuccess_shouldSetUserOnlineAndNavigate() {
        // Given
        let name = "Test User"
        let nickname = "testNickname"
        mockProfileService.isNicknameAvailableResult = true
        mockProfileService.saveProfileResult = .success(())

        let expectation = self.expectation(description: "Profile save and navigation")
        mockView.onNavigateToHome = {
            expectation.fulfill()
        }
        
        // When
        sut.startButtonTapped(name: name, nickname: nickname)
        
        // Then
        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
            XCTAssertTrue(self.mockPresenceService.setUserStatusCalled)
            XCTAssertTrue(self.mockPresenceService.setUserStatusOnline)
            XCTAssertTrue(self.mockView.navigateToHomeCalled)
            XCTAssertTrue(self.mockView.showLoadingCalled)
            XCTAssertEqual(self.mockView.showLoadingIsLoading, false)
        }
    }
    
    func test_startButtonTapped_whenProfileSaveFailure_shouldShowError() {
        // Given
        let name = "Test User"
        let nickname = "testNickname"
        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockProfileService.isNicknameAvailableResult = true
        mockProfileService.saveProfileResult = .failure(error)

        let expectation = self.expectation(description: "Show error on profile save failure")
        mockView.onShowError = {
            expectation.fulfill()
        }

        // When
        sut.startButtonTapped(name: name, nickname: nickname)

        // Then
        waitForExpectations(timeout: 1) { _ in
            XCTAssertTrue(self.mockView.showErrorCalled)
            XCTAssertEqual(self.mockView.showErrorMessage, error.localizedDescription)
            XCTAssertTrue(self.mockView.enableStartButtonCalled)
            XCTAssertEqual(self.mockView.enableStartButtonIsEnabled, true)
            XCTAssertTrue(self.mockView.showLoadingCalled)
            XCTAssertEqual(self.mockView.showLoadingIsLoading, false)
        }
    }
    
    func test_startButtonTapped_whenProfileSaveFailure_shouldNotSetUserOnline() {
        // Given
        let name = "Test User"
        let nickname = "testNickname"
        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockProfileService.isNicknameAvailableResult = true
        mockProfileService.saveProfileResult = .failure(error)
        
        // When
        sut.startButtonTapped(name: name, nickname: nickname)
        
        // Then
        XCTAssertFalse(mockPresenceService.setUserStatusCalled)
        XCTAssertFalse(mockView.navigateToHomeCalled)
    }
    
    func test_startButtonTapped_withoutSelectedImage_shouldStillSaveProfile() {
        // Given
        let name = "Test User"
        let nickname = "testNickname"
        mockProfileService.isNicknameAvailableResult = true
        mockProfileService.saveProfileResult = .success(())
        
        // When
        sut.startButtonTapped(name: name, nickname: nickname)
        
        // Then
        XCTAssertTrue(mockProfileService.saveProfileCalled)
        XCTAssertNil(mockProfileService.saveProfileImage)
    }
}

// Mock classes are now defined in FillProfileMocks.swift 
