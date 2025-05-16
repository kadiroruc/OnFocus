//
//  FillProfileViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 25.03.2025.
//

import UIKit

protocol FillProfileViewInterface: AnyObject{
    func navigateToHome()
    func showError(message: String)
    func setProfileImage(_ image: UIImage)
    func showLoading(_ isLoading: Bool)
    func enableStartButton(_ isEnabled: Bool)
}

final class FillProfileViewController: UIViewController {
    private var viewModel: FillProfileViewModelInterface
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Fill Your Profile"
        label.font = UIFont(name: "Poppins-Bold", size: 28)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: "333333", alpha: 1)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't worry, you can change it later, or you can skip it for now."
        label.font = UIFont(name: "Poppins-Regular", size: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(hex: "444444", alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(UIColor(hex: "#FFB570"), renderingMode: .alwaysOriginal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let changeProfileButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22)
        let image = UIImage(systemName: "square.and.pencil.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(hex: "#333333")
        button.backgroundColor = UIColor(hex: "#FEF6F0")
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name"
        tf.textColor = UIColor(hex: "333333")
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(hex: "#333333").cgColor
        tf.layer.cornerRadius = 14
        tf.backgroundColor = .white
        tf.font = UIFont(name: "Poppins-SemiBold", size: 15)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.setLeftPadding(12)
        return tf
    }()
    
    private let nicknameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nickname"
        tf.textColor = UIColor(hex: "333333")
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(hex: "#333333").cgColor
        tf.layer.cornerRadius = 14
        tf.backgroundColor = .white
        tf.font = UIFont(name: "Poppins-SemiBold", size: 15)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.setLeftPadding(12)
        return tf
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "#FF8A5C")
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "#70C1B3")
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }()
    
    // MARK: - Initializer
    init(viewModel: FillProfileViewModelInterface) {
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
        view.setGradientBackground(colors: [UIColor(hex: "#FEF6F0"), .white])
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(profileImageView)
        view.addSubview(changeProfileButton)
        view.addSubview(nameTextField)
        view.addSubview(nicknameTextField)
        view.addSubview(skipButton)
        view.addSubview(startButton)
        view.addSubview(activityIndicator)
        
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        changeProfileButton.addTarget(self, action: #selector(changeProfileTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            profileImageView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 70),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 130),
            profileImageView.heightAnchor.constraint(equalToConstant: 130),
            
            changeProfileButton.widthAnchor.constraint(equalToConstant: 30),
            changeProfileButton.heightAnchor.constraint(equalToConstant: 30),
            changeProfileButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -6),
            changeProfileButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -6),
            
            nameTextField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 50),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            nicknameTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 15),
            nicknameTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            nicknameTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            nicknameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            skipButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            skipButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            skipButton.heightAnchor.constraint(equalToConstant: 50),
            
            startButton.bottomAnchor.constraint(equalTo: skipButton.bottomAnchor),
            startButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            startButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            startButton.heightAnchor.constraint(equalTo: skipButton.heightAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 40),
            activityIndicator.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func skipTapped() {
        viewModel.skipButtonTapped()
    }
    
    @objc private func startTapped() {
        viewModel.startButtonTapped(name: nameTextField.text, nickname: nicknameTextField.text)
    }
    
    @objc private func changeProfileTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
}

extension FillProfileViewController: FillProfileViewInterface {
    func navigateToHome() {
        // Ana ekran ViewController'ını göster
        let tabBar = TabBarModuleBuilder.build()
        tabBar.modalPresentationStyle = .fullScreen
        present(tabBar, animated: true)
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func setProfileImage(_ image: UIImage) {
        profileImageView.image = image
    }
    
    func showLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }
    
    func enableStartButton(_ isEnabled: Bool) {
        startButton.isEnabled = isEnabled
        startButton.backgroundColor = isEnabled ? UIColor(hex: "#70C1B3") : UIColor(hex: "#A5A5A5")
        startButton.setTitleColor(isEnabled ? .white : UIColor(hex: "#333333"), for: .normal)
        startButton.layer.borderWidth = isEnabled ? 0 : 1
        startButton.layer.borderColor = isEnabled ? UIColor.clear.cgColor : UIColor(hex: "#333333").cgColor
    }
}

extension  FillProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let editedImage = info[.editedImage] as? UIImage {
            viewModel.setSelectedImage(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            viewModel.setSelectedImage(originalImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
    
    

//
//#Preview("FillProfileViewController"){
//    FillProfileViewController(viewModel: FillProfileViewModel(authService: AuthService()))
//}
