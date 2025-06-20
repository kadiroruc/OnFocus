//
//  SettingsCollectionViewCell.swift
//  Test
//
//  Created by Abdulkadir Oruç on 10.03.2025.
//

import UIKit

class SettingsCollectionViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.backgroundColor = .clear
        iv.layer.cornerRadius = 4
        iv.clipsToBounds = true
        iv.tintColor = UIColor(hex: Constants.Colors.softOrange, alpha: 1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        lbl.textColor = UIColor(hex: Constants.Colors.darkGray)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let switchButton: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.onTintColor = UIColor(hex: Constants.Colors.mintGreen)
        return sw
    }()
    
    var switchAction: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        switchButton.addTarget(self, action: #selector(switchTapped(_:)), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(settingsModel: SettingsModel, switchAction: ((Bool) -> Void)? = nil) {
        imageView.image = settingsModel.image
        label.text = settingsModel.text
        switchButton.isOn = settingsModel.switchOn
        switchButton.isHidden = settingsModel.isSwitchHidden
        self.switchAction = switchAction
    }
    
    private func setupUI() {
        
        backgroundColor = .white
        layer.cornerRadius = 8

        
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.addSubview(switchButton)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30),
            
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            switchButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            label.trailingAnchor.constraint(lessThanOrEqualTo: switchButton.leadingAnchor, constant: -12)
        ])
    }
    
    @objc private func switchTapped(_ sender: UISwitch) {
        switchAction?(sender.isOn)
    }
}

//#Preview("SettingsViewController"){
//    SettingsViewController()
//}

