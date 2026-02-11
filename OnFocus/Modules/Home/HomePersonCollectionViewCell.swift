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
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private var isShowingPlaceholder = false
    
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
        contentView.layoutMargins = .zero
        contentView.addSubview(profileImageView)
        
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            profileImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            profileImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    // MARK: - Configure Method
    func configure(with imageUrl: String, status: String?) {
        let placeholder = placeholderImage(pointSize: max(contentView.bounds.width, contentView.bounds.height))
        if let url = URL(string: imageUrl) {
            isShowingPlaceholder = true
            profileImageView.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]) { [weak self] _ in
                    self?.isShowingPlaceholder = false
                }
        } else {
            profileImageView.image = placeholder
            isShowingPlaceholder = true
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isShowingPlaceholder {
            profileImageView.image = placeholderImage(pointSize: max(contentView.bounds.width, contentView.bounds.height))
        }
    }
    
    private func placeholderImage(pointSize: CGFloat) -> UIImage? {
        let size = max(pointSize, 1)
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: .regular, scale: .large)
        return UIImage(systemName: Constants.Icons.personCircle, withConfiguration: config)?
            .withAlignmentRectInsets(.zero)
            .withTintColor(UIColor(hex: Constants.Colors.darkGray), renderingMode: .alwaysOriginal)
    }
}
