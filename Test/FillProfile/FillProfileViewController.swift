//
//  FillProfileViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 25.03.2025.
//

import UIKit

class FillProfileViewController: UIViewController {

    @IBOutlet var changeProfileButton: UIButton!
    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet var nameTextField: UITextField!
    
    @IBOutlet var nicknameTextField: UITextField!
    
    @IBOutlet var skipButton: UIButton!
    
    @IBOutlet var startButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI(){
        nameTextField.textColor = .black
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor(.white).cgColor
        nameTextField.layer.cornerRadius = 14
        nameTextField.clipsToBounds = true
        nameTextField.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        nameTextField.font = UIFont(name: "Poppins-SemiBold", size: 15)
        
        nicknameTextField.textColor = .black
        nicknameTextField.layer.borderWidth = 1
        nicknameTextField.layer.borderColor = UIColor(.white).cgColor
        nicknameTextField.layer.cornerRadius = 14
        nicknameTextField.clipsToBounds = true
        nicknameTextField.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        nicknameTextField.font = UIFont(name: "Poppins-SemiBold", size: 15)
        
        changeProfileButton.setImage(UIImage(systemName: "square.and.pencil.circle.fill"), for: .normal)
        changeProfileButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25), forImageIn: .normal)
        
        skipButton.layer.cornerRadius = 25
        startButton.layer.cornerRadius = 25
    }

    @IBAction func skipButtonTapped(_ sender: Any) {
    }
    @IBAction func startButtonTapped(_ sender: Any) {
    }
}
