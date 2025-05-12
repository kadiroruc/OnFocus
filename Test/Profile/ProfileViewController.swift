//
//  ProfileViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 11.04.2025.
//

import UIKit
import FSCalendar

class ProfileViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    private let addFriendBarButtonItem : UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(systemName: Constants.Icons.personBadgePlus)?.withTintColor(UIColor(hex: "#333333", alpha: 1), renderingMode: .alwaysOriginal)
        return item
    }()
    
    private let menuBarButtonItem : UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(systemName: Constants.Icons.ellipsis)?.withTintColor(UIColor(hex: "#333333", alpha: 1), renderingMode: .alwaysOriginal)
        return item
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 60
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "person.circle")
        iv.tintColor = UIColor(hex: "#333333", alpha: 1)
        return iv
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "Label"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let averageWorkTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Average Work Hour: 7"
        label.textColor = .white
        label.backgroundColor = UIColor(hex: "#70C1B3")
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let streakDayLabel: UILabel = {
        let label = UILabel()
        label.text = "Current Streak Day: 280"
        label.textColor = .white
        label.backgroundColor = UIColor(hex: "#FF8A5C")
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let leftTimeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let image = UIImage(systemName: "lessthan", withConfiguration: config)?.withTintColor(UIColor(hex: "#333333", alpha: 1), renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let rightTimeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let image = UIImage(systemName: "greaterthan", withConfiguration: config)?.withTintColor(UIColor(hex: "#333333", alpha: 1), renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "JAN 2022"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: "#333333", alpha: 1)
        return label
    }()
    
    private let streakView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let lineView : UIView = {
        let lineView = UIView()
        lineView.backgroundColor = .systemGray4
        lineView.translatesAutoresizingMaskIntoConstraints = false
        return lineView
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.text = "MON     TUE     WED     THU     FRI     SAT     SUN"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .justified
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: "#333333", alpha: 1)
        return label
    }()
    
    
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isScrollEnabled = false
        return cv
    }()
    
    private let calendar: FSCalendar = {
        let cal = FSCalendar()
        cal.translatesAutoresizingMaskIntoConstraints = false
        return cal
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.setGradientBackground(colors: [UIColor(hex: "#FEF6F0"), .white])
    }
    
    private func setupViews() {
        view.addSubview(profileImageView)
        view.addSubview(nicknameLabel)
        view.addSubview(averageWorkTimeLabel)
        view.addSubview(streakDayLabel)
        view.addSubview(calendar)
        calendar.delegate = self
        calendar.dataSource = self
        
        navigationItem.rightBarButtonItems = [menuBarButtonItem, addFriendBarButtonItem]
    }
    
    private func setupConstraints() {
        
        var streakViewCons = [
            streakView.topAnchor.constraint(equalTo: streakDayLabel.bottomAnchor,constant: 40),
            streakView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            streakView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            streakView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ]
                              
        
        NSLayoutConstraint.activate([
            
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nicknameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nicknameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            averageWorkTimeLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 30),
            averageWorkTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            averageWorkTimeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            averageWorkTimeLabel.heightAnchor.constraint(equalToConstant: 40),
            
            calendar.topAnchor.constraint(equalTo: streakDayLabel.bottomAnchor, constant: 40),
            calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            streakDayLabel.topAnchor.constraint(equalTo: averageWorkTimeLabel.bottomAnchor, constant: 10),
            streakDayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            streakDayLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            streakDayLabel.heightAnchor.constraint(equalToConstant: 40),
            
           
        ])
        
        if traitCollection.userInterfaceIdiom == .pad {
            
//            NSLayoutConstraint.deactivate(streakViewCons)
//            NSLayoutConstraint.activate([
//                streakView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                streakView.topAnchor.constraint(equalTo: streakDayLabel.bottomAnchor,constant: 150),
//                
//            streakView.heightAnchor.constraint(equalToConstant: 340)
//            
//            ])

        }else{
//            NSLayoutConstraint.activate(streakViewCons)
        }
    }
    
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("Seçilen tarih: \(date)")
    }
}


#Preview("ProfileViewController"){
    ProfileViewController()
}

