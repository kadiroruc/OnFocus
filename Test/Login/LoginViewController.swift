//
//  LoginViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 9.03.2025.
//

import UIKit

protocol LoginViewInterface: AnyObject {
    // Interface methods if needed
}

class LoginViewController: UIViewController, LoginViewInterface {
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Login to your Account"
        label.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        label.numberOfLines = 2
        label.textColor = UIColor(hex: "#333333")
        return label
    }()
    
    private let emailIconView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 40))
        let imageView = UIImageView(image: UIImage(systemName: "envelope.fill"))
        imageView.tintColor = .gray
        imageView.frame = CGRect(x: 15, y: 10, width: 22, height: 20)
        view.addSubview(imageView)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Email"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = UIColor(hex: "#333333")
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 14
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(hex: "333333").cgColor
        tf.leftViewMode = .always
        return tf
    }()
    
    private let passwordIconView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 40))
        let imageView = UIImageView(image: UIImage(systemName: "lock.fill"))
        imageView.tintColor = .gray
        imageView.frame = CGRect(x: 16, y: 10, width: 20, height: 20)
        view.addSubview(imageView)
        return view
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Password"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = UIColor(hex: "#333333")
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 14
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(hex: "333333").cgColor
        tf.isSecureTextEntry = true
        tf.leftViewMode = .always
        tf.rightViewMode = .always
        return tf
    }()
    
    private let showPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        btn.setImage(UIImage(systemName: "eye.slash", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(hex: "#444444")
        return btn
    }()
    
    private let rememberMeCheckbox: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "square"), for: .normal)
        btn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        btn.tintColor = UIColor(hex: "333333")
        btn.backgroundColor = .clear
        return btn
    }()
    
    private let rememberMeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Remember me"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()
    
    private let signInButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Sign in", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(hex: "#70C1B3")
        btn.layer.cornerRadius = 13
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return btn
    }()
    
    private let forgotPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Forgot the password?", for: .normal)
        btn.setTitleColor(UIColor(hex: "FF8A5C"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "New Here?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()
    
    private let signUpButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Sign Up", for: .normal)
        btn.setTitleColor(UIColor(hex: "#FF8A5C"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return btn
    }()
    
    // MARK: - ViewModel
    private lazy var viewModel = LoginViewModel()
    
    // MARK: - Lifecycle
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        setupUI()
        setupLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.setGradientBackground(colors: [UIColor(hex: "#FEF6F0"), .white])
    }
    
    // MARK: - Setup
    private func setupUI() {
        [titleLabel, emailTextField, passwordTextField,
         showPasswordButton, rememberMeCheckbox, rememberMeLabel,
         signInButton, forgotPasswordButton, bottomLabel, signUpButton].forEach {
            view.addSubview($0)
        }
        emailTextField.leftView = emailIconView
        passwordTextField.leftView = passwordIconView
        passwordTextField.rightView = showPasswordButton
        
        showPasswordButton.addTarget(self, action: #selector(showPasswordButtonTapped), for: .touchUpInside)
        rememberMeCheckbox.addTarget(self, action: #selector(rememberMeTapped), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Email
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            emailTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Password
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalTo: emailTextField.heightAnchor),
            
            // Show Password Button size
            showPasswordButton.widthAnchor.constraint(equalToConstant: 30),
            showPasswordButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Remember Me
            rememberMeCheckbox.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            rememberMeCheckbox.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor,constant: 2),
            rememberMeCheckbox.widthAnchor.constraint(equalToConstant: 24),
            rememberMeCheckbox.heightAnchor.constraint(equalToConstant: 24),
            rememberMeLabel.centerYAnchor.constraint(equalTo: rememberMeCheckbox.centerYAnchor),
            rememberMeLabel.leadingAnchor.constraint(equalTo: rememberMeCheckbox.trailingAnchor, constant: 4),
            
            // Sign In Button
            signInButton.topAnchor.constraint(equalTo: rememberMeCheckbox.bottomAnchor, constant: 30),
            signInButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            signInButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Forgot Password
            forgotPasswordButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 16),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Bottom Sign Up
            bottomLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -40),
            signUpButton.centerYAnchor.constraint(equalTo: bottomLabel.centerYAnchor),
            signUpButton.leadingAnchor.constraint(equalTo: bottomLabel.trailingAnchor, constant: 4)
        ])
    }
    
    // MARK: - Actions
    @objc private func showPasswordButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let name = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        showPasswordButton.setImage(UIImage(systemName: name, withConfiguration: config), for: .normal)
    }
    
    @objc private func rememberMeTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    @objc private func loginButtonTapped() {
        //viewModel.login(email: emailTextField.text,password: passwordTextField.text)
    }
    
    @objc private func forgotPasswordTapped() {
        // Handle forgot password
    }
    
    @objc private func signUpTapped() {
        // Handle sign up
    }
}

#Preview("LoginViewController"){
    LoginViewController()
}
