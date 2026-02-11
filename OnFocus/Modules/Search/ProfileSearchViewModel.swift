//
//  ProfileSearchViewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 5.06.2025.
//

import Foundation

protocol ProfileSearchViewModelInterface {
    var view: ProfileSearchViewInterface? { get set }
    
    var filteredProfiles: [ProfileModel] { get }
    func searchBarSearchButtonClicked(_ searchText: String)
    func searchTextChanged(_ searchText: String)
    func didSelectItemAt(indexPath: IndexPath)
}
    

final class ProfileSearchViewModel{
    weak var view: ProfileSearchViewInterface?
    
    var filteredProfiles: [ProfileModel] = []
    
    private let profileService: ProfileServiceProtocol

    //MARK: - Init
    init(profileService: ProfileServiceProtocol) {
        self.profileService = profileService
    }
}

extension ProfileSearchViewModel: ProfileSearchViewModelInterface {
    func didSelectItemAt(indexPath: IndexPath) {
        view?.navigateToProfileDetail(profile: filteredProfiles[indexPath.item])
    }
    
    func searchBarSearchButtonClicked(_ searchText: String) {
        searchTextChanged(searchText)
    }
    
    func searchTextChanged(_ searchText: String) {
        if searchText.isEmpty {
            filteredProfiles = []
            view?.setNoResultsHidden(false)
            view?.reloadData()
            return
        }
        
        view?.showLoading(true)
        view?.setNoResultsHidden(true)
        profileService.searchProfiles(matching: searchText) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profiles):
                self.filteredProfiles = profiles
                self.view?.reloadData()
                self.view?.showLoading(false)
                self.view?.setNoResultsHidden(!filteredProfiles.isEmpty)
            case .failure(let error):
                print("Profile Search Error: \(error)")
                self.view?.showLoading(false)
            }
        }
    }
}
