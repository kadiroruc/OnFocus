//
//  LeaderboardBottomSheetCollectionViewCell.swift
//  Test
//
//  Created by Abdulkadir Oruç on 13.06.2025.
//

import UIKit
import Kingfisher

final class LeaderboardBottomSheetCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "LeaderboardBottomSheetCollectionViewCell"
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
       let iv = UIImageView()
       iv.contentMode = .scaleAspectFill
       iv.layer.cornerRadius = 25
       iv.clipsToBounds = true
       iv.translatesAutoresizingMaskIntoConstraints = false
       return iv
    }()
    
    private let nicknameLabel: UILabel = {
       let label = UILabel()
       label.font = .systemFont(ofSize: 17)
       label.textColor = .black
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true
        
        contentView.addSubview(rankLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        
        NSLayoutConstraint.activate([
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 30),
            
            profileImageView.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 8),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nicknameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nicknameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            nicknameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(rank: Int, profile: ProfileModel) {
        rankLabel.text = "\(rank)"
        nicknameLabel.text = profile.nickname
        if let urlString = profile.profileImageURL, let url = URL(string: urlString) {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(systemName: Constants.Icons.person)?.withTintColor(UIColor(hex: Constants.Colors.darkGray)).withRenderingMode(.alwaysOriginal))
        } else {
            profileImageView.image = UIImage(systemName: Constants.Icons.personCropCircleFill)?.withTintColor(UIColor(hex: Constants.Colors.darkGray)).withRenderingMode(.alwaysOriginal)
        }
    }
}
