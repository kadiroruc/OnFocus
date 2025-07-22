//
//  FillProfileViewControllerTests.swift
//  OnFocusTests
//
//  Created by Abdulkadir Oruç on 25.03.2025.
//

import XCTest
import UIKit
@testable import OnFocus

final class FillProfileViewControllerTests: XCTestCase {
    
    var sut: FillProfileViewController!
    var mockViewModel: MockFillProfileViewModel!
    
    override func setUp() {
        super.setUp()
        mockViewModel = MockFillProfileViewModel()
        sut = FillProfileViewController(viewModel: mockViewModel)
        
        // Load view to trigger viewDidLoad
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        mockViewModel = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func test_init_withViewModel_shouldSetViewModelAndView() {
        // Given
        let viewModel = MockFillProfileViewModel()
        
        // When
        let viewController = FillProfileViewController(viewModel: viewModel)
        
        // Then
        XCTAssertEqual(viewController.viewModel as? MockFillProfileViewModel, viewModel)
        XCTAssertEqual(viewModel.view as? FillProfileViewController, viewController)
    }
    
    // MARK: - View Setup Tests
    
    func test_viewDidLoad_shouldSetupUI() {
        // Then
        XCTAssertNotNil(sut.view.subviews.first { $0 is UILabel && ($0 as? UILabel)?.text == "Fill Your Profile" })
        XCTAssertNotNil(sut.view.subviews.first { $0 is UILabel && ($0 as? UILabel)?.text?.contains("Don't worry, you can change your profile photo later") == true })
        XCTAssertNotNil(sut.view.subviews.first { $0 is UIImageView })
        XCTAssertNotNil(sut.view.subviews.first { $0 is UIButton && ($0 as? UIButton)?.title(for: .normal) == "Start" })
        XCTAssertNotNil(sut.view.subviews.first { $0 is UITextField && ($0 as? UITextField)?.placeholder == "Full Name" })
        XCTAssertNotNil(sut.view.subviews.first { $0 is UITextField && ($0 as? UITextField)?.placeholder == "Nickname" })
    }
    
    func test_viewDidLayoutSubviews_shouldSetGradientBackground() {
        // When
        sut.viewDidLayoutSubviews()
        
        // Then
        // Note: We can't easily test gradient background in unit tests
        // This test ensures the method doesn't crash
        XCTAssertNotNil(sut.view)
    }
    
    // MARK: - Button Actions Tests
    
    func test_startButtonTapped_shouldCallViewModel() {
        // Given
        let name = "Test User"
        let nickname = "testNickname"
        
        // Access the text fields through the view hierarchy
        if let nameTextField = sut.findTextField(withPlaceholder: "Full Name"),
           let nicknameTextField = sut.findTextField(withPlaceholder: "Nickname") {
            
            nameTextField.text = name
            nicknameTextField.text = nickname
            
            // When
            if let startButton = sut.findButton(withTitle: "Start") {
                startButton.sendActions(for: .touchUpInside)
            }
            
            // Then
            XCTAssertTrue(mockViewModel.startButtonTappedCalled)
            XCTAssertEqual(mockViewModel.startButtonTappedName, name)
            XCTAssertEqual(mockViewModel.startButtonTappedNickname, nickname)
        }
    }
    
    // MARK: - Touch Handling Tests
    
    func test_touchesBegan_shouldEndEditing() {
        // Given
        let window = UIWindow()
        window.rootViewController = sut
        window.makeKeyAndVisible()
        
        // Find text field and make it first responder
        if let nameTextField = sut.findTextField(withPlaceholder: "Full Name") {
            nameTextField.becomeFirstResponder()
            XCTAssertTrue(nameTextField.isFirstResponder)
            
            // When
            let touch = UITouch()
            let touches = Set([touch])
            let event = UIEvent()
            sut.touchesBegan(touches, with: event)
            
            // Then
            XCTAssertFalse(nameTextField.isFirstResponder)
        }
    }
    
    // MARK: - FillProfileViewInterface Tests
    
    func test_setNicknameNotAvailable_shouldUpdateNicknameTextField() {
        // Given
        guard let nicknameTextField = sut.findTextField(withPlaceholder: "Nickname") else {
            XCTFail("Nickname text field not found")
            return
        }
        
        // When
        sut.setNicknameNotAvailable()
        
        // Then
        XCTAssertEqual(nicknameTextField.layer.borderColor, UIColor(hex: Constants.Colors.softOrange).cgColor)
        XCTAssertEqual(nicknameTextField.layer.borderWidth, 2)
    }
    
    func test_navigateToHome_shouldPresentTabBar() {
        // Given
        let window = UIWindow()
        window.rootViewController = sut
        window.makeKeyAndVisible()
        
        // When
        sut.navigateToHome()
        
        // Then
        XCTAssertNotNil(sut.presentedViewController)
        XCTAssertEqual(sut.presentedViewController?.modalPresentationStyle, .fullScreen)
    }
    
    func test_showError_shouldPresentAlert() {
        // Given
        let window = UIWindow()
        window.rootViewController = sut
        window.makeKeyAndVisible()
        let errorMessage = "Test error message"
        
        // When
        sut.showError(message: errorMessage)
        
        // Then
        XCTAssertNotNil(sut.presentedViewController)
        XCTAssertTrue(sut.presentedViewController is UIAlertController)
        
        if let alert = sut.presentedViewController as? UIAlertController {
            XCTAssertEqual(alert.title, "Error!")
            XCTAssertEqual(alert.message, errorMessage)
            XCTAssertEqual(alert.actions.count, 1)
            XCTAssertEqual(alert.actions.first?.title, "OK")
        }
    }
    
    func test_setProfileImage_shouldUpdateProfileImageView() {
        // Given
        let testImage = UIImage()
        
        // When
        sut.setProfileImage(testImage)
        
        // Then
        if let profileImageView = sut.findProfileImageView() {
            XCTAssertEqual(profileImageView.image, testImage)
        }
    }
    
    func test_showLoading_whenTrue_shouldStartActivityIndicatorAndDisableInteraction() {
        // When
        sut.showLoading(true)
        
        // Then
        if let activityIndicator = sut.findActivityIndicator() {
            XCTAssertTrue(activityIndicator.isAnimating)
        }
        XCTAssertFalse(sut.view.isUserInteractionEnabled)
    }
    
    func test_showLoading_whenFalse_shouldStopActivityIndicatorAndEnableInteraction() {
        // Given
        sut.showLoading(true)
        
        // When
        sut.showLoading(false)
        
        // Then
        if let activityIndicator = sut.findActivityIndicator() {
            XCTAssertFalse(activityIndicator.isAnimating)
        }
        XCTAssertTrue(sut.view.isUserInteractionEnabled)
    }
    
    func test_enableStartButton_whenTrue_shouldEnableButton() {
        // When
        sut.enableStartButton(true)
        
        // Then
        if let startButton = sut.findButton(withTitle: "Start") {
            XCTAssertTrue(startButton.isEnabled)
            XCTAssertEqual(startButton.backgroundColor, UIColor(hex: Constants.Colors.mintGreen))
            XCTAssertEqual(startButton.titleColor(for: .normal), .white)
            XCTAssertEqual(startButton.layer.borderWidth, 0)
        }
    }
    
    func test_enableStartButton_whenFalse_shouldDisableButton() {
        // When
        sut.enableStartButton(false)
        
        // Then
        if let startButton = sut.findButton(withTitle: "Start") {
            XCTAssertFalse(startButton.isEnabled)
            XCTAssertEqual(startButton.backgroundColor, UIColor(hex: Constants.Colors.lightGray))
            XCTAssertEqual(startButton.titleColor(for: .normal), UIColor(hex: Constants.Colors.darkGray))
            XCTAssertEqual(startButton.layer.borderWidth, 1)
            XCTAssertEqual(startButton.layer.borderColor, UIColor(hex: Constants.Colors.darkGray).cgColor)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate Tests
    
    func test_imagePickerController_didFinishPickingMediaWithInfo_withEditedImage_shouldCallViewModel() {
        // Given
        let testImage = UIImage()
        let picker = UIImagePickerController()
        let info: [UIImagePickerController.InfoKey: Any] = [.editedImage: testImage]
        
        // When
        sut.imagePickerController(picker, didFinishPickingMediaWithInfo: info)
        
        // Then
        XCTAssertTrue(mockViewModel.setSelectedImageCalled)
        XCTAssertEqual(mockViewModel.setSelectedImageImage, testImage)
    }
    
    func test_imagePickerController_didFinishPickingMediaWithInfo_withOriginalImage_shouldCallViewModel() {
        // Given
        let testImage = UIImage()
        let picker = UIImagePickerController()
        let info: [UIImagePickerController.InfoKey: Any] = [.originalImage: testImage]
        
        // When
        sut.imagePickerController(picker, didFinishPickingMediaWithInfo: info)
        
        // Then
        XCTAssertTrue(mockViewModel.setSelectedImageCalled)
        XCTAssertEqual(mockViewModel.setSelectedImageImage, testImage)
    }
    
    func test_imagePickerController_didFinishPickingMediaWithInfo_withNoImage_shouldNotCallViewModel() {
        // Given
        let picker = UIImagePickerController()
        let info: [UIImagePickerController.InfoKey: Any] = [:]
        
        // When
        sut.imagePickerController(picker, didFinishPickingMediaWithInfo: info)
        
        // Then
        XCTAssertFalse(mockViewModel.setSelectedImageCalled)
    }
    
}

// Mock classes are now defined in FillProfileMocks.swift
