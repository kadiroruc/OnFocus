//
//  LoginViewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 9.03.2025.
//

import UIKit

protocol LoginViewModelInterface{
    var view: LoginViewInterface? { get set }
    func viewDidLoad()
    func offlineButtonTapped()
    
}

final class LoginViewModel{
    weak var view: LoginViewInterface?
    
}

extension LoginViewModel: LoginViewModelInterface{
    func viewDidLoad() {
        
    }
    
    func offlineButtonTapped() {
    }
    
    
}
