//
//  SignUpViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 9.03.2025.
//

import UIKit

protocol SignUpViewInterface: AnyObject, SeguePerformable{
    
}

class SignUpViewController: UIViewController {

    @IBOutlet var nameTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var signUpButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI(){
        signUpButton.layer.cornerRadius = 12
        
        nameTextField.backgroundColor = .clear
        nameTextField.textColor = .white
        nameTextField.setPlaceholder(color: .systemGray6, text: "Name Surname")
        nameTextField.setBottomBorder(color: .systemGray6)
        
        emailTextField.backgroundColor = .clear
        emailTextField.textColor = .white
        emailTextField.setPlaceholder(color: .systemGray6, text: "Email")
        emailTextField.setBottomBorder(color: .systemGray6)
        
        passwordTextField.backgroundColor = .clear
        passwordTextField.textColor = .white
        passwordTextField.setPlaceholder(color: .systemGray6, text: "Password")
        passwordTextField.setBottomBorder(color: .systemGray6)
        
        
    }
    
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
