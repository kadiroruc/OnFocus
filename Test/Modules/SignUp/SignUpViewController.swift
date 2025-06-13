//
//  SignUpViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 9.03.2025.
//

import UIKit

protocol SignUpViewInterface: AnyObject{
    // UI güncellemeleri
    func showLoading(_ isLoading: Bool)
    func showError(message: String)
    
    // Form ile ilgili işlemler
    func enableSignUpButton(_ isEnabled: Bool)
    
    // Navigasyon
    func navigateToLogin()
    func navigateToFillProfile()
}

final class SignUpViewController: UIViewController{
    private var viewModel : SignUpViewModelInterface
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create your\nAccount"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 42,weight: .bold)
        label.textColor = UIColor(hex: Constants.Colors.darkGray)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailIconView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 40))
        let imageView = UIImageView(image: UIImage(systemName: Constants.Icons.envelopeFill))
        imageView.tintColor = .gray
        imageView.frame = CGRect(x: 15, y: 10, width: 24, height: 20)
        view.addSubview(imageView)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Email"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.layer.cornerRadius = 14
        tf.layer.borderWidth = 1
        tf.backgroundColor = .white
        tf.textColor = UIColor(hex: Constants.Colors.darkGray)
        tf.layer.borderColor = UIColor(hex: Constants.Colors.darkGray).cgColor
        tf.leftViewMode = .always
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let passwordIconView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 40))
        let imageView = UIImageView(image: UIImage(systemName: Constants.Icons.lockFill))
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
        tf.layer.cornerRadius = 14
        tf.layer.borderWidth = 1
        tf.backgroundColor = .white
        tf.textColor = UIColor(hex: Constants.Colors.darkGray)
        tf.layer.borderColor = UIColor(hex: Constants.Colors.darkGray).cgColor
        tf.isSecureTextEntry = true
        tf.leftViewMode = .always
        tf.rightViewMode = .always
        return tf
    }()
    
    private let showPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        btn.setImage(UIImage(systemName: Constants.Icons.eye, withConfiguration: config), for: .normal)
        btn.tintColor = .gray
        return btn
    }()
    
    private let rememberMeCheckbox: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: Constants.Icons.square), for: .normal)
        btn.setImage(UIImage(systemName: Constants.Icons.checkmarkSquareFill), for: .selected)
        btn.tintColor = UIColor(hex: Constants.Colors.darkGray)
        btn.backgroundColor = .clear
        return btn
    }()
    
    private let rememberMeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Remember me"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: Constants.Colors.darkGray)
        return label
    }()
    
    private let signUpButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Sign up", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(hex: Constants.Colors.mintGreen)
        btn.layer.cornerRadius = 17
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return btn
    }()

    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = "Have an account?"
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: Constants.Colors.mediumDarkGray)
        return label
    }()

    private let signInLinkButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Sign in", for: .normal)
        btn.setTitleColor(UIColor(hex: Constants.Colors.softOrange), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return btn
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }()
    
    //MARK: - Init Functions
    init(viewModel : SignUpViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.view = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.setGradientBackground(colors: [UIColor(hex: Constants.Colors.lightPeach), .white])
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
        view.addSubview(activityIndicator)
        
        //Setup Actions
        showPasswordButton.addTarget(self, action: #selector(showPasswordButtonTapped), for: .touchUpInside)
        rememberMeCheckbox.addTarget(self, action: #selector(rememberMeCheckboxTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        signInLinkButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        
        
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
            signInLinkButton.leadingAnchor.constraint(equalTo: bottomLabel.trailingAnchor, constant: 4),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 40),
            activityIndicator.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - Actions
    @objc private func showPasswordButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        let imageName = passwordTextField.isSecureTextEntry ? Constants.Icons.eyeSlash : Constants.Icons.eye
        let image = UIImage(systemName: imageName, withConfiguration: config)
        showPasswordButton.setImage(image, for: .normal)
    }

    @objc private func rememberMeCheckboxTapped() {
        rememberMeCheckbox.isSelected.toggle()
        viewModel.rememberMeTapped(isSelected: rememberMeCheckbox.isSelected)
    }

    @objc private func signUpTapped() {
        viewModel.signUpTapped(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
    }

    @objc private func signInTapped() {
        viewModel.signInTapped()
    }
}

extension SignUpViewController: SignUpViewInterface{
    
    func showLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func enableSignUpButton(_ isEnabled: Bool) {
        signUpButton.isEnabled = isEnabled
        signUpButton.alpha = isEnabled ? 1.0 : 0.5
    }
    
    func navigateToLogin() {
        dismiss(animated: true)
    }
    
    func navigateToFillProfile() {
        let fillProfileVC = DIContainer.shared.makeFillProfileViewController()
        fillProfileVC.modalPresentationStyle = .fullScreen
        present(fillProfileVC, animated: true)
    }
    
    
}

//#Preview("SignUpViewController"){
//    
//}
