//
//  SettingsViewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 10.03.2025.
//

import UIKit

protocol SettingsViewModelInterface{
    var view: SettingsViewInterface? { get set }
    //func viewDidLoad()
    func getSetting(at index: Int) -> SettingsModel
    func numberOfSettings() -> Int
    func tappedSwitchAction(for index: Int, isOn: Bool)
    func tappedSetting(at: Int)

}

final class SettingsViewModel{
    weak var view: SettingsViewInterface?
    
    private let profileService: ProfileServiceProtocol
    
    init (profileService: ProfileServiceProtocol) {
        self.profileService = profileService
    }
    
    var isTimeKeeperModeOn: Bool {
        get { UserDefaults.standard.bool(forKey: "isTimeKeeperModeOn") }
        set { UserDefaults.standard.set(newValue, forKey: "isTimeKeeperModeOn") }
    }
    
    private var settingsData: [SettingsModel] {
        return [
            SettingsModel(
                image: UIImage(systemName: Constants.Icons.deskClock)!,
                text: "Timekeeper Mode",
                switchOn: isTimeKeeperModeOn,
                isSwitchHidden: false
            ),
            SettingsModel(
                image: UIImage(
                    systemName: Constants.Icons.xmarkBin
                )!,
                text: "Delete Account",
                switchOn: false,
                isSwitchHidden: true
            ),
            SettingsModel(
                image: UIImage(
                    systemName: Constants.Icons.xmarkIcloud
                )!,
                text: "Delete Data",
                switchOn: false,
                isSwitchHidden: true
            ),
//            SettingsModel(
//                image: UIImage(
//                    systemName: Constants.Icons.speakerWave2
//                )!,
//                text: "Audible Alerts",
//                switchOn: false
//            )
        ]
    }
    
}

extension SettingsViewModel: SettingsViewModelInterface{
    func tappedSetting(at: Int) {
        switch at {
        case 1:
            view?.showMessage("Are you sure you want to delete your account? This action cannot be undone.", type: .warning, isCancelEnabled: true) { [weak self] in
                guard let self = self else { return }
                
                self.profileService.deleteProfile { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self.view?.showMessage("Account deleted successfully.", type: .success, isCancelEnabled: false) {
                                self.view?.navigateToLogin()
                            }
                        case .failure(let error):
                            self.view?.showMessage(error.localizedDescription, type: .error, isCancelEnabled: false, nil)
                        }
                    }
                }
            }
            case 2:
            view?.showMessage("Are you sure you want to delete your data? This action cannot be undone.", type: .warning, isCancelEnabled: true) { [weak self] in
                guard let self = self else { return }
                
                self.profileService.deleteStatisticsAndFriendships { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self.view?.showMessage("Data deleted successfully.", type: .success, isCancelEnabled: false, nil)
                        case .failure(let error):
                            self.view?.showMessage(error.localizedDescription, type: .error, isCancelEnabled: false, nil)
                        }
                    }
                }
            }
        default:
            return
        }

        
    }
    
    func tappedSwitchAction(for index: Int, isOn: Bool) {
        switch index{
        case 0:
            isTimeKeeperModeOn = isOn
            view?.changeTimerMode(timeKeeperMode: isOn)
            
        default:
            return
        }
    }
    
    
    func getSetting(at index: Int) -> SettingsModel {
        return settingsData[index]
    }
    
    func numberOfSettings() -> Int {
        return settingsData.count
    }
    
}

