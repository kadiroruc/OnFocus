//
//  NotificationsCell.swift
//  Test
//
//  Created by Abdulkadir Oruç on 22.04.2025.
//


import UIKit
import Kingfisher

protocol NotificationsCellDelegate: AnyObject {
    func didTapAccept(at indexPath: IndexPath)
    func didTapDecline(at indexPath: IndexPath)
}

class NotificationsCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: NotificationsCellDelegate?
    private var indexPath: IndexPath?
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .medium)
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
        button.addTarget(self, action: #selector(declineTapped), for: .touchUpInside)
        return button
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: Constants.Icons.checkmark), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(hex: Constants.Colors.mintGreen)
        button.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
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
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
            
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            
            acceptButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            acceptButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            declineButton.trailingAnchor.constraint(equalTo: acceptButton.leadingAnchor, constant: -12),
            declineButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            
        ])
    }
    
    func configure(with model: NotificationModel, at indexPath: IndexPath, delegate: NotificationsCellDelegate) {
        self.indexPath = indexPath
        self.delegate = delegate
        
        // Kullanıcı ismini ayarla
        label.text = "\(model.user.nickname) sent you a friend request"
        
        // Ortak placeholder ayarı
        let inset: CGFloat = 8
        let rawPlaceholder = UIImage(systemName: Constants.Icons.person)?
            .withTintColor(UIColor(hex: Constants.Colors.darkGray), renderingMode: .alwaysOriginal)
        let paddedPlaceholder = rawPlaceholder?.withAlignmentRectInsets(
            UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        )
        
        // Profil resmini yükle (varsa)
        if let urlString = model.user.profileImageURL, let url = URL(string: urlString) {
            imageView.kf.setImage(
                with: url,
                placeholder: paddedPlaceholder,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            imageView.image = paddedPlaceholder
        }

        // Eğer pending istekse butonları göster
        let isPending = model.type == Constants.Firebase.pending
        acceptButton.isHidden = !isPending
        declineButton.isHidden = !isPending
    }

    
    @objc private func acceptTapped() {
        guard let indexPath = indexPath else { return }
        delegate?.didTapAccept(at: indexPath)
    }

    @objc private func declineTapped() {
        guard let indexPath = indexPath else { return }
        delegate?.didTapDecline(at: indexPath)
    }

        
}



