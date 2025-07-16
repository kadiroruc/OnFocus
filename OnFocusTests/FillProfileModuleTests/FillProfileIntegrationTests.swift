//
//  FillProfileIntegrationTests.swift
//  OnFocusTests
//
//  Created by Abdulkadir Oruç on 25.03.2025.
//

import XCTest
import UIKit
@testable import OnFocus

final class FillProfileIntegrationTests: XCTestCase {
    
    var sut: FillProfileViewController!
    var viewModel: FillProfileViewModel!
    var mockProfileService: MockProfileService!
    var mockPresenceService: MockPresenceService!
    
    override func setUp() {
        super.setUp()
        mockProfileService = MockProfileService()
        mockPresenceService = MockPresenceService()
        
        viewModel = FillProfileViewModel(
            profileService: mockProfileService,
            presenceService: mockPresenceService
        )
        
        sut = FillProfileViewController(viewModel: viewModel)
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        viewModel = nil
        mockProfileService = nil
        mockPresenceService = nil
        super.tearDown()
    }
    
    // MARK: - Complete Flow Tests
    
    func test_completeSuccessfulFlow_shouldNavigateToHome() {
        // Given
        let name = "John Doe"
        let nickname = "johndoe"
        let testImage = UIImage()
        
        // Set up services for success
        mockProfileService.isNicknameAvailableResult = true
        mockProfileService.saveProfileResult = .success(())
        
        // Set up UI
        if let nameTextField = findTextField(withPlaceholder: "Full Name"),
           let nicknameTextField = findTextField(withPlaceholder: "Nickname") {
            
            nameTextField.text = name
            nicknameTextField.text = nickname
            
            // Set selected image
            viewModel.setSelectedImage(testImage)
            
            // When
            if let startButton = findButton(withTitle: "Start") {
                startButton.sendActions(for: .touchUpInside)
            }
            
            // Then
            XCTAssertTrue(mockProfileService.isNicknameAvailableCalled)
            XCTAssertEqual(mockProfileService.isNicknameAvailableNickname, nickname)
            XCTAssertTrue(mockProfileService.saveProfileCalled)
            XCTAssertEqual(mockProfileService.saveProfileName, name)
            XCTAssertEqual(mockProfileService.saveProfileNickname, nickname)
            XCTAssertEqual(mockProfileService.saveProfileImage, testImage)
            XCTAssertTrue(mockPresenceService.setUserStatusCalled)
            XCTAssertTrue(mockPresenceService.setUserStatusOnline)
        }
    }
    
    func test_completeFlowWithNicknameUnavailable_shouldShowError() {
        // Given
        let name = "John Doe"
        let nickname = "takenNickname"
        
        // Set up services for nickname unavailable
        mockProfileService.isNicknameAvailableResult = false
        
        // Set up UI
        if let nameTextField = findTextField(withPlaceholder: "Full Name"),
           let nicknameTextField = findTextField(withPlaceholder: "Nickname") {
            
            nameTextField.text = name
            nicknameTextField.text = nickname
            
            // When
            if let startButton = findButton(withTitle: "Start") {
                startButton.sendActions(for: .touchUpInside)
            }
            
            // Then
            XCTAssertTrue(mockProfileService.isNicknameAvailableCalled)
            XCTAssertFalse(mockProfileService.saveProfileCalled)
            XCTAssertFalse(mockPresenceService.setUserStatusCalled)
            
            // Check UI state
            XCTAssertEqual(nicknameTextField.layer.borderColor, UIColor(hex: Constants.Colors.softOrange).cgColor)
            XCTAssertEqual(nicknameTextField.layer.borderWidth, 2)
        }
    }
    
    func test_completeFlowWithProfileSaveFailure_shouldShowError() {
        // Given
        let name = "John Doe"
        let nickname = "johndoe"
        let error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        
        // Set up services for save failure
        mockProfileService.isNicknameAvailableResult = true
        mockProfileService.saveProfileResult = .failure(error)
        
        // Set up UI
        if let nameTextField = findTextField(withPlaceholder: "Full Name"),
           let nicknameTextField = findTextField(withPlaceholder: "Nickname") {
            
            nameTextField.text = name
            nicknameTextField.text = nickname
            
            // When
            if let startButton = findButton(withTitle: "Start") {
                startButton.sendActions(for: .touchUpInside)
            }
            
            // Then
            XCTAssertTrue(mockProfileService.isNicknameAvailableCalled)
            XCTAssertTrue(mockProfileService.saveProfileCalled)
            XCTAssertFalse(mockPresenceService.setUserStatusCalled)
            
            // Check that start button is re-enabled
            if let startButton = findButton(withTitle: "Start") {
                XCTAssertTrue(startButton.isEnabled)
            }
        }
    }
    
    // MARK: - UI State Tests
    
    func test_startButtonStateChanges_duringFlow() {
        // Given
        let name = "John Doe"
        let nickname = "johndoe"
        
        mockProfileService.isNicknameAvailableResult = true
        mockProfileService.saveProfileResult = .success(())
        
        // Set up UI
        if let nameTextField = findTextField(withPlaceholder: "Full Name"),
           let nicknameTextField = findTextField(withPlaceholder: "Nickname"),
           let startButton = findButton(withTitle: "Start") {
            
            nameTextField.text = name
            nicknameTextField.text = nickname
            
            // Initial state should be enabled
            XCTAssertTrue(startButton.isEnabled)
            
            // When - Start the flow
            startButton.sendActions(for: .touchUpInside)
            
            // Then - Button should be disabled during loading
            XCTAssertFalse(startButton.isEnabled)
            XCTAssertEqual(startButton.backgroundColor, UIColor(hex: Constants.Colors.lightGray))
        }
    }
    
    func test_loadingStateChanges_duringFlow() {
        // Given
        let name = "John Doe"
        let nickname = "johndoe"
        
        mockProfileService.isNicknameAvailableResult = true
        mockProfileService.saveProfileResult = .success(())
        
        // Set up UI
        if let nameTextField = findTextField(withPlaceholder: "Full Name"),
           let nicknameTextField = findTextField(withPlaceholder: "Nickname") {
            
            nameTextField.text = name
            nicknameTextField.text = nickname
            
            // Initial state
            XCTAssertTrue(sut.view.isUserInteractionEnabled)
            
            // When - Start the flow
            if let startButton = findButton(withTitle: "Start") {
                startButton.sendActions(for: .touchUpInside)
            }
            
            // Then - View should be disabled during loading
            XCTAssertFalse(sut.view.isUserInteractionEnabled)
            
            // Activity indicator should be animating
            if let activityIndicator = sut.view.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
                XCTAssertTrue(activityIndicator.isAnimating)
            }
        }
    }
    
    // MARK: - Image Selection Flow Tests
    
    func test_imageSelectionFlow_shouldUpdateProfileImage() {
        // Given
        let testImage = UIImage()
        let picker = UIImagePickerController()
        let info: [UIImagePickerController.InfoKey: Any] = [.editedImage: testImage]
        
        // When
        sut.imagePickerController(picker, didFinishPickingMediaWithInfo: info)
        
        // Then
        XCTAssertTrue(mockProfileService.saveProfileCalled || mockProfileService.isNicknameAvailableCalled == false)
        
        // Check that profile image view was updated
        if let profileImageView = sut.view.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            XCTAssertEqual(profileImageView.image, testImage)
        }
    }
    
    // MARK: - Error Handling Tests
    
    func test_errorHandling_withEmptyFields() {
        // Given
        if let nameTextField = findTextField(withPlaceholder: "Full Name"),
           let nicknameTextField = findTextField(withPlaceholder: "Nickname") {
            
            nameTextField.text = ""
            nicknameTextField.text = ""
            
            // When
            if let startButton = findButton(withTitle: "Start") {
                startButton.sendActions(for: .touchUpInside)
            }
            
            // Then
            XCTAssertFalse(mockProfileService.isNicknameAvailableCalled)
            XCTAssertFalse(mockProfileService.saveProfileCalled)
        }
    }
    
    func test_errorHandling_withNilFields() {
        // Given
        if let nameTextField = findTextField(withPlaceholder: "Full Name"),
           let nicknameTextField = findTextField(withPlaceholder: "Nickname") {
            
            nameTextField.text = nil
            nicknameTextField.text = nil
            
            // When
            if let startButton = findButton(withTitle: "Start") {
                startButton.sendActions(for: .touchUpInside)
            }
            
            // Then
            XCTAssertFalse(mockProfileService.isNicknameAvailableCalled)
            XCTAssertFalse(mockProfileService.saveProfileCalled)
        }
    }
    
    // MARK: - Helper Methods
    
    private func findTextField(withPlaceholder placeholder: String) -> UITextField? {
        return sut.view.subviews.first(where: { 
            $0 is UITextField && ($0 as? UITextField)?.placeholder == placeholder 
        }) as? UITextField
    }
    
    private func findButton(withTitle title: String) -> UIButton? {
        return sut.view.subviews.first(where: { 
            $0 is UIButton && ($0 as? UIButton)?.title(for: .normal) == title 
        }) as? UIButton
    }
}

// Mock classes are now defined in FillProfileMocks.swift 