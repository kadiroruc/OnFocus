//
//  FillProfileViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 25.03.2025.
//

import UIKit

class FillProfileViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Fill Your Profile"
        label.font = UIFont(name: "Poppins-Bold", size: 28)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't worry, you can change it later, or you can skip it for now."
        label.font = UIFont(name: "Poppins-Regular", size: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.tintColor = .systemGray4
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.tintColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        return imageView
    }()
    
    private let changeProfileButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22)
        let image = UIImage(systemName: "square.and.pencil.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name"
        tf.textColor = .black
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.white.cgColor
        tf.layer.cornerRadius = 14
        tf.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        tf.font = UIFont(name: "Poppins-SemiBold", size: 15)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.setLeftPadding(12)
        return tf
    }()
    
    private let nicknameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nickname"
        tf.textColor = .black
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.white.cgColor
        tf.layer.cornerRadius = 14
        tf.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        tf.font = UIFont(name: "Poppins-SemiBold", size: 15)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.setLeftPadding(12)
        return tf
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.backgroundColor = UIColor.systemGray5
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 234/255, green: 64/255, blue: 52/255, alpha: 1)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        view = UIView()
        view.backgroundColor = .white
        setupUI()
        setupLayout()
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
        
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        changeProfileButton.addTarget(self, action: #selector(changeProfileTapped), for: .touchUpInside)
    }
    
    private func setupLayout() {
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
            
            nameTextField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 30),
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
            startButton.heightAnchor.constraint(equalTo: skipButton.heightAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func skipTapped() {
        print("Skip tapped")
    }
    
    @objc private func startTapped() {
        print("Start tapped")
    }
    
    @objc private func changeProfileTapped() {
        print("Change profile tapped")
    }
}

#Preview("FillProfileViewController"){
    FillProfileViewController()
}
