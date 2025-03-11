//
//  SettingsCollectionViewCell.swift
//  Test
//
//  Created by Abdulkadir Oruç on 10.03.2025.
//

import UIKit

class SettingsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
    @IBOutlet var switchButton: UISwitch!
    
    func setupCell(settingsModel: SettingsModel){
        
        self.imageView.image = settingsModel.image
        self.label.text = settingsModel.text
        self.switchButton.isOn = settingsModel.switchOn
        
    }
    
    @IBAction func switchTapped(_ sender: Any) {
        
        print("asdfas")
    }
    
    
}
