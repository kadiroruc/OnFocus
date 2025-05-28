//
//  HomePersonCollectionViewCell.swift
//  Test
//
//  Created by Abdulkadir Oruç on 26.03.2025.
//

import UIKit

class HomePersonCollectionViewCell: UICollectionViewCell {
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        layer.cornerRadius = 25
        clipsToBounds = true
        layer.borderColor = UIColor(hex: Constants.Colors.mintGreen).cgColor
        layer.borderWidth = 4
        contentMode = .scaleAspectFit
        
        
        contentView.addSubview(profileImageView)
        
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalTo: self.widthAnchor,multiplier: 0.8),
            profileImageView.heightAnchor.constraint(equalTo: self.heightAnchor,multiplier: 0.8),
        ])
    }
}
