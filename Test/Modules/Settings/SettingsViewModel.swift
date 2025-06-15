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

}

final class SettingsViewModel{
    weak var view: SettingsViewInterface?
    
    
    var isTimeKeeperModeOn: Bool {
        get { UserDefaults.standard.bool(forKey: "isTimeKeeperModeOn") }
        set { UserDefaults.standard.set(newValue, forKey: "isTimeKeeperModeOn") }
    }
    
    private var settingsData: [SettingsModel] {
        return [
            SettingsModel(
                image: UIImage(systemName: Constants.Icons.deskClock)!,
                text: "Timekeeper Mode",
                switchOn: isTimeKeeperModeOn
            ),
//            SettingsModel(
//                image: UIImage(
//                    systemName: Constants.Icons.arrowCirclePath
//                )!,
//                text: "Auto Start",
//                switchOn: false
//            ),
//            SettingsModel(
//                image: UIImage(
//                    systemName: Constants.Icons.bell
//                )!,
//                text: "Notifications",
//                switchOn: false
//            ),
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

