//
//  FillProfileTestHelpers.swift
//  OnFocusTests
//
//  Created by Abdulkadir Oruç on 25.03.2025.
//

import XCTest
import UIKit
@testable import OnFocus

// MARK: - Test Helpers

extension XCTestCase {
    
    /// Creates a test window and adds the view controller to it
    func createTestWindow(with viewController: UIViewController) -> UIWindow {
        let window = UIWindow()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        return window
    }
    
    /// Waits for a condition to be true with a timeout
    func waitForCondition(_ condition: @escaping () -> Bool, timeout: TimeInterval = 1.0, message: String = "") {
        let expectation = XCTestExpectation(description: message.isEmpty ? "Condition met" : message)
        
        DispatchQueue.main.async {
            if condition() {
                expectation.fulfill()
            } else {
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    if condition() {
                        expectation.fulfill()
                        timer.invalidate()
                    }
                }
            }
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    /// Creates a test image for testing purposes
    func createTestImage(size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

// MARK: - FillProfileViewController Test Extensions

extension FillProfileViewController {
    
    /// Helper method to find text field by placeholder
    func findTextField(withPlaceholder placeholder: String) -> UITextField? {
        return view.subviews.first(where: { 
            $0 is UITextField && ($0 as? UITextField)?.placeholder == placeholder 
        }) as? UITextField
    }
    
    /// Helper method to find button by title
    func findButton(withTitle title: String) -> UIButton? {
        return view.subviews.first(where: { 
            $0 is UIButton && ($0 as? UIButton)?.title(for: .normal) == title 
        }) as? UIButton
    }
    
    func findButton(withImage image: UIImage?) -> UIButton? {
        return view.subviews.first(where: {
            guard let button = $0 as? UIButton else { return false }
            return button.image(for: .normal) == image
        }) as? UIButton
    }
    
    /// Helper method to find profile image view
    func findProfileImageView() -> UIImageView? {
        return view.subviews.first(where: { $0 is UIImageView }) as? UIImageView
    }
    
    /// Helper method to find activity indicator
    func findActivityIndicator() -> UIActivityIndicatorView? {
        return view.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView
    }
    
    /// Helper method to simulate user input
    func simulateUserInput(name: String, nickname: String) {
        if let nameTextField = findTextField(withPlaceholder: "Full Name") {
            nameTextField.text = name
        }
        if let nicknameTextField = findTextField(withPlaceholder: "Nickname") {
            nicknameTextField.text = nickname
        }
    }
    
    /// Helper method to simulate start button tap
    func simulateStartButtonTap() {
        if let startButton = findButton(withTitle: "Start") {
            startButton.sendActions(for: .touchUpInside)
        }
    }
    
    /// Helper method to simulate profile image selection
    func simulateImageSelection(image: UIImage) {
        let picker = UIImagePickerController()
        let info: [UIImagePickerController.InfoKey: Any] = [.editedImage: image]
        imagePickerController(picker, didFinishPickingMediaWithInfo: info)
    }
}

// MARK: - Mock Service Builders

class MockServiceBuilder {
    
    /// Creates a mock profile service with predefined behavior
    static func createMockProfileService(
        isNicknameAvailableResult: Bool = true,
        saveProfileResult: Result<Void, Error> = .success(())
    ) -> MockProfileService {
        let service = MockProfileService()
        service.isNicknameAvailableResult = isNicknameAvailableResult
        service.saveProfileResult = saveProfileResult
        return service
    }
    
    /// Creates a mock presence service
    static func createMockPresenceService() -> MockPresenceService {
        return MockPresenceService()
    }
    
    /// Creates a mock view model with predefined behavior
    static func createMockViewModel(
        startButtonTappedResult: (name: String?, nickname: String?) = (nil, nil),
        setSelectedImageResult: UIImage? = nil
    ) -> MockFillProfileViewModel {
        let viewModel = MockFillProfileViewModel()
        viewModel.startButtonTappedName = startButtonTappedResult.name
        viewModel.startButtonTappedNickname = startButtonTappedResult.nickname
        viewModel.setSelectedImageImage = setSelectedImageResult
        return viewModel
    }
}

// MARK: - Test Data

struct FillProfileTestData {
    
    static let validName = "John Doe"
    static let validNickname = "johndoe"
    static let invalidName = ""
    static let invalidNickname = ""
    static let takenNickname = "takenNickname"
    
    static let testImage = UIImage()
    static let testError = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error message"])
    
    static let validInputs = (name: validName, nickname: validNickname)
    static let invalidInputs = (name: invalidName, nickname: invalidNickname)
    static let mixedInputs = (name: validName, nickname: invalidNickname)
}

// MARK: - Assertion Helpers

extension XCTestCase {
    
    /// Asserts that the view controller shows an alert with specific title and message
    func assertAlertIsPresented(
        on viewController: UIViewController,
        title: String? = nil,
        message: String? = nil,
        actionCount: Int? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let alert = viewController.presentedViewController as? UIAlertController else {
            XCTFail("No alert controller is presented", file: file, line: line)
            return
        }
        
        if let expectedTitle = title {
            XCTAssertEqual(alert.title, expectedTitle, "Alert title mismatch", file: file, line: line)
        }
        
        if let expectedMessage = message {
            XCTAssertEqual(alert.message, expectedMessage, "Alert message mismatch", file: file, line: line)
        }
        
        if let expectedActionCount = actionCount {
            XCTAssertEqual(alert.actions.count, expectedActionCount, "Alert action count mismatch", file: file, line: line)
        }
    }
    
    /// Asserts that the text field has specific border properties
    func assertTextFieldBorder(
        _ textField: UITextField,
        color: CGColor? = nil,
        width: CGFloat? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        if let expectedColor = color {
            XCTAssertEqual(textField.layer.borderColor, expectedColor, "Border color mismatch", file: file, line: line)
        }
        
        if let expectedWidth = width {
            XCTAssertEqual(textField.layer.borderWidth, expectedWidth, "Border width mismatch", file: file, line: line)
        }
    }
    
    /// Asserts that the button has specific properties
    func assertButtonProperties(
        _ button: UIButton,
        isEnabled: Bool? = nil,
        backgroundColor: UIColor? = nil,
        titleColor: UIColor? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        if let expectedEnabled = isEnabled {
            XCTAssertEqual(button.isEnabled, expectedEnabled, "Button enabled state mismatch", file: file, line: line)
        }
        
        if let expectedBackgroundColor = backgroundColor {
            XCTAssertEqual(button.backgroundColor, expectedBackgroundColor, "Button background color mismatch", file: file, line: line)
        }
        
        if let expectedTitleColor = titleColor {
            XCTAssertEqual(button.titleColor(for: .normal), expectedTitleColor, "Button title color mismatch", file: file, line: line)
        }
    }
    
    /// Asserts that the activity indicator is in the expected state
    func assertActivityIndicatorState(
        _ activityIndicator: UIActivityIndicatorView,
        isAnimating: Bool,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(activityIndicator.isAnimating, isAnimating, "Activity indicator animation state mismatch", file: file, line: line)
    }
}

// MARK: - Test Scenarios

struct FillProfileTestScenarios {
    
    /// Test scenario for successful profile creation
    static func successfulProfileCreation(
        name: String = FillProfileTestData.validName,
        nickname: String = FillProfileTestData.validNickname,
        image: UIImage? = FillProfileTestData.testImage
    ) -> (name: String, nickname: String, image: UIImage?) {
        return (name: name, nickname: nickname, image: image)
    }
    
    /// Test scenario for nickname already taken
    static func nicknameTaken(
        name: String = FillProfileTestData.validName,
        nickname: String = FillProfileTestData.takenNickname
    ) -> (name: String, nickname: String) {
        return (name: name, nickname: nickname)
    }
    
    /// Test scenario for network error
    static func networkError(
        name: String = FillProfileTestData.validName,
        nickname: String = FillProfileTestData.validNickname,
        error: Error = FillProfileTestData.testError
    ) -> (name: String, nickname: String, error: Error) {
        return (name: name, nickname: nickname, error: error)
    }
    
    /// Test scenario for validation error
    static func validationError(
        name: String = FillProfileTestData.invalidName,
        nickname: String = FillProfileTestData.invalidNickname
    ) -> (name: String, nickname: String) {
        return (name: name, nickname: nickname)
    }
} 
