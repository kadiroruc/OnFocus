//
//  LoginViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 9.03.2025.
//

import UIKit

protocol LoginViewInterface: AnyObject, SeguePerformable{
    
}

class LoginViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var offlineButton: UIButton!
    
    private lazy var viewModel = LoginViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI(){
        loginButton.layer.cornerRadius = 12
        offlineButton.layer.cornerRadius = 12
        
        emailTextField.backgroundColor = .clear
        emailTextField.textColor = .white
        emailTextField.setPlaceholder(color: .systemGray6, text: "Email")
        emailTextField.setBottomBorder(color: .systemGray6)
        
        passwordTextField.backgroundColor = .clear
        passwordTextField.textColor = .white
        passwordTextField.setPlaceholder(color: .systemGray6, text: "Password")
        passwordTextField.setBottomBorder(color: .systemGray6)
        
        
    }
    
    @IBAction func offlineButtonTapped(_ sender: Any) {
        viewModel.offlineButtonTapped()
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
    }
    
}

extension LoginViewController: LoginViewInterface{
    
}
