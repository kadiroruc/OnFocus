//
//  NotificationsCell.swift
//  Test
//
//  Created by Abdulkadir Oruç on 22.04.2025.
//


import UIKit
import Kingfisher

class NotificationsCollectionViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        lbl.textColor = .black
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = UIColor(hex: Constants.Colors.darkGray)
        return lbl
    }()
    
    let declineButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: Constants.Icons.xmark), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(hex: Constants.Colors.softOrange)
        return button
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: Constants.Icons.checkmark), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(hex: Constants.Colors.mintGreen)
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.addSubview(declineButton)
        contentView.addSubview(acceptButton)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            
            acceptButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            acceptButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            declineButton.trailingAnchor.constraint(equalTo: acceptButton.leadingAnchor, constant: -12),
            declineButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            
        ])
    }
    
    func configure(with model: NotificationModel) {
        // Kullanıcı ismini ayarla
        label.text = "\(model.user.nickname) sent you a friend request"
        
        // Profil resmini ayarla (varsayılan görsel yedeğiyle)
        if let urlString = model.user.profileImageURL, let url = URL(string: urlString) {
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "defaultProfile"))
        } else {
            imageView.image = UIImage(named: "defaultProfile")
        }
        
        // İstek "pending" mi, değil mi kontrolü
        let isPending = model.type == Constants.Firebase.pending
        acceptButton.isHidden = !isPending
        declineButton.isHidden = !isPending
    }
        
}



