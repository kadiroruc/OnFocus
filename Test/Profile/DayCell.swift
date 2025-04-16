//
//  DayCell.swift
//  Test
//
//  Created by Abdulkadir Oruç on 11.04.2025.
//
import UIKit

class DayCell: UICollectionViewCell {
    let circleView = UIView()
    let fireIcon = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Circle
        circleView.layer.cornerRadius = 11
        circleView.clipsToBounds = true
        contentView.addSubview(circleView)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 22),
            circleView.heightAnchor.constraint(equalToConstant: 22),
        ])
        
        // Fire Icon
        fireIcon.image = UIImage(systemName: "flame.fill") // veya özel emoji/icon
        fireIcon.tintColor = .red
        fireIcon.isHidden = true
        contentView.addSubview(fireIcon)
        fireIcon.translatesAutoresizingMaskIntoConstraints = false
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
