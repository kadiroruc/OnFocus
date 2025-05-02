//
//  SignUpViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 9.03.2025.
//

import UIKit

protocol SignUpViewInterface: AnyObject{
    
}

class SignUpViewController: UIViewController, SignUpViewInterface {
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create your\nAccount"
        label.numberOfLines = 0
        label.font = UIFont(name: "Poppins-Bold", size: 42)
        label.translatesAutoresizingMaskIntoConstraints = false
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
        tf.textColor = .black
        tf.backgroundColor = UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1)
        tf.layer.cornerRadius = 14
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray5.cgColor
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
        tf.textColor = .black
        tf.backgroundColor = UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1)
        tf.layer.cornerRadius = 14
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray5.cgColor
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
        btn.tintColor = .gray
        return btn
    }()
    
    private let rememberMeCheckbox: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "square"), for: .normal)
        btn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        btn.tintColor = .red
        return btn
    }()
    
    private let rememberMeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Remember me"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    private let signUpButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Sign up", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 234/255, green: 64/255, blue: 52/255, alpha: 1)
        btn.layer.cornerRadius = 17
        return btn
    }()

    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = "Have an account?"
        label.text = text
        label.font = UIFont(name: "Poppins-Regular", size: 14)
        label.textColor = .lightGray
        return label
    }()

    private let signInLinkButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Sign in", for: .normal)
        btn.setTitleColor(UIColor(red: 234/255, green: 64/255, blue: 52/255, alpha: 1), for: .normal)
        btn.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 14)
        return btn
    }()

    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        view = UIView()
        view.backgroundColor = .white
        setupUI()
        setupLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Setup
    private func setupUI() {
        emailTextField.leftView = emailIconView
        passwordTextField.leftView = passwordIconView
        passwordTextField.rightView = showPasswordButton

        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(rememberMeCheckbox)
        view.addSubview(rememberMeLabel)
        view.addSubview(signUpButton)
        view.addSubview(bottomLabel)
        view.addSubview(signInLinkButton)

        showPasswordButton.addTarget(self, action: #selector(showPasswordButtonTapped), for: .touchUpInside)
        rememberMeCheckbox.addTarget(self, action: #selector(checkBoxTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        signInLinkButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
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
            rememberMeCheckbox.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: -60),
            rememberMeCheckbox.widthAnchor.constraint(equalToConstant: 24),
            rememberMeCheckbox.heightAnchor.constraint(equalToConstant: 24),
            rememberMeLabel.centerYAnchor.constraint(equalTo: rememberMeCheckbox.centerYAnchor),
            rememberMeLabel.leadingAnchor.constraint(equalTo: rememberMeCheckbox.trailingAnchor, constant: 6),
            
            // Sign In Button
            signUpButton.topAnchor.constraint(equalTo: rememberMeCheckbox.bottomAnchor, constant: 30),
            signUpButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            
            // Bottom Sign Up
            bottomLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -40),
            signInLinkButton.centerYAnchor.constraint(equalTo: bottomLabel.centerYAnchor),
            signInLinkButton.leadingAnchor.constraint(equalTo: bottomLabel.trailingAnchor, constant: 4)
        ])
    }

    // MARK: - Actions
    @objc private func showPasswordButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        let imageName = passwordTextField.isSecureTextEntry ? Constants.Icons.eyeSlash : Constants.Icons.eyeSlash
        let image = UIImage(systemName: imageName, withConfiguration: config)
        showPasswordButton.setImage(image, for: .normal)
    }

    @objc private func checkBoxTapped() {
        rememberMeCheckbox.isSelected.toggle()
    }

    @objc private func signUpTapped() {
        // Handle sign up logic
    }

    @objc private func signInTapped() {
        dismiss(animated: true)
    }
}

#Preview("SignUpViewController"){
    SignUpViewController()
}
