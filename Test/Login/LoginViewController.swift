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
    @IBOutlet var emailIconView: UIView!
    
    @IBOutlet var passwordIconView: UIView!
    @IBOutlet var showPasswordButton: UIButton!
    @IBOutlet var checkBox: UIButton!
    private lazy var viewModel = LoginViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
        
        setupUI()
        
    }
    
    func setupUI(){
        loginButton.layer.cornerRadius = 17
        
        emailTextField.textColor = .black
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor(.white).cgColor
        emailTextField.layer.cornerRadius = 14
        emailTextField.clipsToBounds = true
        emailTextField.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        emailTextField.leftView = emailIconView
        emailTextField.leftViewMode = .always
        emailTextField.font = UIFont(name: "Poppins-SemiBold", size: 15)
        
        emailIconView.backgroundColor = .clear
        passwordIconView.backgroundColor = .clear
        
        showPasswordButton.backgroundColor = .clear
        
        
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        let image = UIImage(systemName: Constants.Icons.eyeSlash, withConfiguration: config)
        showPasswordButton.setImage(image, for: .normal)

        
        passwordTextField.textColor = .black
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor(.white).cgColor
        passwordTextField.layer.cornerRadius = 14
        passwordTextField.clipsToBounds = true
        passwordTextField.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        passwordTextField.leftView = passwordIconView
        passwordTextField.leftViewMode = .always
        passwordTextField.rightViewMode = .always
        passwordTextField.font = UIFont(name: "Poppins-SemiBold", size: 15)
        passwordTextField.rightView = showPasswordButton
        
        checkBox.setImage(UIImage(systemName: "square"), for: .normal)
        checkBox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        
        
    }
    
    
    @IBAction func registerButtonTapped(_ sender: Any) {
    }
    
    @IBAction func showPasswordButtonTapped(_ sender: Any) {
    }
    @IBAction func checkBoxTapped(_ sender: Any) {
        if let button = sender as? UIButton{
            button.isSelected.toggle()
        }
    }
    
    
}

extension LoginViewController: LoginViewInterface{
    
}
