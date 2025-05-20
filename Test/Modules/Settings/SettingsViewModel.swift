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
    func configureCell(cell: SettingsCollectionViewCell, at indexPath: IndexPath)
    
}

final class SettingsViewModel{
    weak var view: SettingsViewInterface?
    
    private let settingsData: [SettingsModel] = [SettingsModel(image: UIImage(systemName: Constants.Icons.deskClock)!, text: "Serbest Mod", switchOn: false), SettingsModel(image: UIImage(systemName: Constants.Icons.arrowCirclePath)!, text: "Otomatik Başlatma", switchOn: false ), SettingsModel(image: UIImage(systemName: Constants.Icons.bell)!, text: "Bildirimler", switchOn: true), SettingsModel(image: UIImage(systemName: Constants.Icons.speakerWave2)!, text: "Sesli Uyarılar", switchOn: true)]
    
    func getSetting(at index: Int) -> SettingsModel {
        return settingsData[index]
    }
    
}

extension SettingsViewModel: SettingsViewModelInterface{
//    func viewDidLoad() {
//        
//    }
    
    func configureCell(cell: SettingsCollectionViewCell, at indexPath: IndexPath) {
        cell.setupCell(settingsModel: getSetting(at: indexPath.item))
    }
    
}

