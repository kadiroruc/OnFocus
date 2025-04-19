//
//  DayCell.swift
//  Test
//
//  Created by Abdulkadir Oruç on 11.04.2025.
//
import UIKit

class DayCell: UICollectionViewCell {
    let circleView:UIView = {
        let circleView = UIView()
        circleView.layer.cornerRadius = 14
        circleView.clipsToBounds = true
        circleView.translatesAutoresizingMaskIntoConstraints = false
        return circleView
    }()
    let fireIcon:UIImageView = {
        let fireIcon = UIImageView()
        fireIcon.image = UIImage(systemName: "flame.fill")
        fireIcon.tintColor = .red
        fireIcon.isHidden = true
        fireIcon.translatesAutoresizingMaskIntoConstraints = false
        return fireIcon
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(circleView)
        
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 28),
            circleView.heightAnchor.constraint(equalToConstant: 28),
        ])
        
        contentView.addSubview(fireIcon)
        
        NSLayoutConstraint.activate([
            fireIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            fireIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(isActive: Bool, isStreak: Bool) {
        if isStreak {
            fireIcon.isHidden = false
            circleView.backgroundColor = .clear
        } else if isActive {
            fireIcon.isHidden = true
            circleView.backgroundColor = .systemYellow
        } else {
            fireIcon.isHidden = true
            circleView.backgroundColor = .systemGray5
        }
    }
}
