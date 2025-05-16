//
//  FillProfileViewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 15.05.2025.
//

import UIKit

protocol FillProfileViewModelInterface {
    var view: FillProfileViewInterface? { get set }
    func skipButtonTapped()
    func startButtonTapped(name: String?, nickname: String?)
    func setSelectedImage(_ image: UIImage)
}

final class FillProfileViewModel {
    weak var view: FillProfileViewInterface?
    private let profileService: ProfileServiceProtocol
    private var selectedImage: UIImage?
    
    init(service: ProfileServiceProtocol) {
        self.profileService = service
    }
}

extension FillProfileViewModel: FillProfileViewModelInterface{
    
    func setSelectedImage(_ image: UIImage) {
        selectedImage = image
        view?.setProfileImage(image)
    }
    
    func skipButtonTapped() {
        //view?.navigateToHome()
    }
    
    func startButtonTapped(name: String?, nickname: String?) {
        guard let name = name, !name.isEmpty,
              let nickname = nickname, !nickname.isEmpty else {
            view?.showError(message: "Name and nickname must not be empty.")
            return
        }
        
        view?.enableStartButton(false)
        view?.showLoading(true)
        
        profileService.saveProfile(name: name, nickname: nickname, image: selectedImage) { [weak self] result in
            guard let self = self else { return }
            self.view?.showLoading(false)
            switch result {
            case .success:
                self.view?.navigateToHome()
            case .failure(let error):
                self.view?.showError(message: error.localizedDescription)
                self.view?.enableStartButton(true)
            }
        }
    }
}
