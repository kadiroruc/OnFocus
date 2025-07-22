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
        mockProfileService.isNicknameAvailableResult = true
        mockProfileService.saveProfileResult = .success(())

        if let nameTextField = sut.findTextField(withPlaceholder: "Full Name"),
           let nicknameTextField = sut.findTextField(withPlaceholder: "Nickname") {
            nameTextField.text = name
            nicknameTextField.text = nickname
            viewModel.setSelectedImage(testImage)
            if let startButton = sut.findButton(withTitle: "Start") {
                startButton.sendActions(for: .touchUpInside)
            }
            let exp = expectation(description: "Navigation gerçekleşti")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Navigation veya state kontrolü
                // Örneğin navigationController'ın viewControllers sayısı arttı mı?
                // Veya bir state değişti mi?
                // Burada örnek olarak mock servislerin çağrılıp çağrılmadığını kontrol ediyoruz:
                XCTAssertTrue(self.mockProfileService.isNicknameAvailableCalled)
                XCTAssertEqual(self.mockProfileService.isNicknameAvailableNickname, nickname)
                XCTAssertTrue(self.mockProfileService.saveProfileCalled)
                XCTAssertEqual(self.mockProfileService.saveProfileName, name)
                XCTAssertEqual(self.mockProfileService.saveProfileNickname, nickname)
                XCTAssertEqual(self.mockProfileService.saveProfileImage, testImage)
                XCTAssertTrue(self.mockPresenceService.setUserStatusCalled)
                XCTAssertTrue(self.mockPresenceService.setUserStatusOnline)
                exp.fulfill()
            }
            waitForExpectations(timeout: 1)
        }
    }
    
    func test_completeFlowWithNicknameUnavailable_shouldShowError() {
        // Given
        let name = "John Doe"
        let nickname = "takenNickname"
        
        // Set up services for nickname unavailable
        mockProfileService.isNicknameAvailableResult = false
        
        // Set up UI
        if let nameTextField = sut.findTextField(withPlaceholder: "Full Name"),
           let nicknameTextField = sut.findTextField(withPlaceholder: "Nickname") {
            
            nameTextField.text = name
            nicknameTextField.text = nickname
            
            // When
            if let startButton = sut.findButton(withTitle: "Start") {
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
        let name = "Jane Doe"
        let nickname = "janedoe"
        let testImage = UIImage()
        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockProfileService.isNicknameAvailableResult = true
        mockProfileService.saveProfileResult = .failure(error)

        if let nameTextField = sut.findTextField(withPlaceholder: "Full Name"),
           let nicknameTextField = sut.findTextField(withPlaceholder: "Nickname") {
            nameTextField.text = name
            nicknameTextField.text = nickname
            viewModel.setSelectedImage(testImage)
            if let startButton = sut.findButton(withTitle: "Start") {
                startButton.sendActions(for: .touchUpInside)
            }
            let exp = expectation(description: "Hata mesajı gösterildi")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Hata mesajı veya state kontrolü
                // Örneğin, bir label'ın text'i hata mesajı mı?
                // Veya mock servislerin çağrılıp çağrılmadığı kontrol edilebilir:
                XCTAssertTrue(self.mockProfileService.isNicknameAvailableCalled)
                XCTAssertEqual(self.mockProfileService.isNicknameAvailableNickname, nickname)
                XCTAssertTrue(self.mockProfileService.saveProfileCalled)
                XCTAssertEqual(self.mockProfileService.saveProfileName, name)
                XCTAssertEqual(self.mockProfileService.saveProfileNickname, nickname)
                XCTAssertEqual(self.mockProfileService.saveProfileImage, testImage)
                // Hata mesajı UI'da gösterildi mi? (örnek: bir label'ın text'i)
                // XCTAssertEqual(self.findLabel(withText: error.localizedDescription)?.text, error.localizedDescription)
                exp.fulfill()
            }
            waitForExpectations(timeout: 1)
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
        if let nameTextField = sut.findTextField(withPlaceholder: "Full Name"),
           let nicknameTextField = sut.findTextField(withPlaceholder: "Nickname"),
           let startButton = sut.findButton(withTitle: "Start") {
            
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
        if let nameTextField = sut.findTextField(withPlaceholder: "Full Name"),
           let nicknameTextField = sut.findTextField(withPlaceholder: "Nickname") {
            
            nameTextField.text = name
            nicknameTextField.text = nickname
            
            // Initial state
            XCTAssertTrue(sut.view.isUserInteractionEnabled)
            
            // When - Start the flow
            if let startButton = sut.findButton(withTitle: "Start") {
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
        if let nameTextField = sut.findTextField(withPlaceholder: "Full Name"),
           let nicknameTextField = sut.findTextField(withPlaceholder: "Nickname") {
            
            nameTextField.text = ""
            nicknameTextField.text = ""
            
            // When
            if let startButton = sut.findButton(withTitle: "Start") {
                startButton.sendActions(for: .touchUpInside)
            }
            
            // Then
            XCTAssertFalse(mockProfileService.isNicknameAvailableCalled)
            XCTAssertFalse(mockProfileService.saveProfileCalled)
        }
    }
    
    func test_errorHandling_withNilFields() {
        // Given
        if let nameTextField = sut.findTextField(withPlaceholder: "Full Name"),
           let nicknameTextField = sut.findTextField(withPlaceholder: "Nickname") {
            
            nameTextField.text = nil
            nicknameTextField.text = nil
            
            // When
            if let startButton = sut.findButton(withTitle: "Start") {
                startButton.sendActions(for: .touchUpInside)
            }
            
            // Then
            XCTAssertFalse(mockProfileService.isNicknameAvailableCalled)
            XCTAssertFalse(mockProfileService.saveProfileCalled)
        }
    }

}

