//
//  FillProfileViewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 15.05.2025.
//

import UIKit

protocol FillProfileViewModelInterface {
    var view: FillProfileViewInterface? { get set }
    func startButtonTapped(name: String?, nickname: String?)
    func setSelectedImage(_ image: UIImage)
}

final class FillProfileViewModel {
    weak var view: FillProfileViewInterface?
    private let profileService: ProfileServiceProtocol
    private let presenceService: PresenceServiceProtocol
    private var selectedImage: UIImage?
    
    init(profileService: ProfileServiceProtocol, presenceService: PresenceServiceProtocol) {
        self.profileService = profileService
        self.presenceService = presenceService
    }
}

extension FillProfileViewModel: FillProfileViewModelInterface{
    
    func setSelectedImage(_ image: UIImage) {
        selectedImage = image
        view?.setProfileImage(image)
    }
    
    func startButtonTapped(name: String?, nickname: String?) {
        guard let name = name, !name.isEmpty,
              let nickname = nickname, !nickname.isEmpty else {
            view?.showError(message: Constants.ValidationMessages.fillAllFields)
            return
        }
//        guard let selectedImage = selectedImage else {
//            view?.showError(message: Constants.ValidationMessages.selectImage)
//            return
//        }
        
        view?.enableStartButton(false)
        view?.showLoading(true)
        
        profileService.isNicknameAvailable(nickname) {[weak self]  isAvailable in
            guard let self = self else { return }
            
            if isAvailable {
                self.profileService.saveProfile(name: name, nickname: nickname, image: selectedImage) { result in
                    DispatchQueue.main.async {
                        self.view?.showLoading(false)
                        switch result {
                        case .success:
                            self.presenceService.setUserStatus(online: true)
                            self.view?.navigateToHome()
                        case .failure(let error):
                            self.view?.showError(message: error.localizedDescription)
                            self.view?.enableStartButton(true)
                        }
                    }
                }
            } else {
                self.view?.showLoading(false)
                self.view?.showError(message: Constants.ValidationMessages.nicknameTaken)
                self.view?.setNicknameNotAvailable()
                self.view?.enableStartButton(true)
            }
        }

    }
}
