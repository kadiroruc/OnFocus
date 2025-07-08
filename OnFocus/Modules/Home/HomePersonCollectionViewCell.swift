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
            profileImageView.widthAnchor.constraint(equalTo: self.widthAnchor,multiplier: 0.9),
            profileImageView.heightAnchor.constraint(equalTo: self.heightAnchor,multiplier: 0.9),
        ])
    }
    
    // MARK: - Configure Method
    func configure(with imageUrl: String, status: String?) {
        if let url = URL(string: imageUrl) {
            profileImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: Constants.Icons.personCircle)?.withTintColor(UIColor(hex: Constants.Colors.darkGray), renderingMode: .alwaysOriginal), // isteğe bağlı placeholder
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ])
        } else {
            profileImageView.image = UIImage(systemName: Constants.Icons.personCircle)?.withTintColor(UIColor(hex: Constants.Colors.darkGray), renderingMode: .alwaysOriginal)
        }
        
        
        
        if let status = status {
            if status == "online" {
                layer.borderColor = UIColor(hex: Constants.Colors.mintGreen).cgColor
            } else if status == "offline" {
                layer.borderColor = UIColor(hex: Constants.Colors.darkGray).cgColor
            } else {
                layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
}
