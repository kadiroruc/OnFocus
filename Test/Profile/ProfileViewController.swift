//
//  ProfileViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 11.04.2025.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let addFriendBarButtonItem : UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(systemName: Constants.Icons.personBadgePlus)
        return item
    }()
    
    private let menuBarButtonItem : UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(systemName: Constants.Icons.ellipsis)
        return item
    }()
    
    private let pointsLabel: UILabel = {
        let label = UILabel()
        label.text = "Points: 133423"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 60
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "person.circle")
        iv.tintColor = .systemBlue
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
        label.backgroundColor = .systemRed
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
        label.backgroundColor = .systemRed
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let leftTimeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let image = UIImage(systemName: "lessthan", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let rightTimeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let image = UIImage(systemName: "greaterthan", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "JAN 2022"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let streakView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        setupCollectionView()
    }
    
    private func setupViews() {
        view.addSubview(pointsLabel)
        view.addSubview(profileImageView)
        view.addSubview(nicknameLabel)
        view.addSubview(averageWorkTimeLabel)
        view.addSubview(streakDayLabel)
        view.addSubview(streakView)
        streakView.addSubview(timeLabel)
        streakView.addSubview(leftTimeButton)
        streakView.addSubview(rightTimeButton)
        streakView.addSubview(lineView)
        streakView.addSubview(dayLabel)
        streakView.addSubview(collectionView)
        
        navigationItem.rightBarButtonItems = [menuBarButtonItem, addFriendBarButtonItem]
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            pointsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pointsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: pointsLabel.bottomAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nicknameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nicknameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            averageWorkTimeLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 30),
            averageWorkTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            averageWorkTimeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            averageWorkTimeLabel.heightAnchor.constraint(equalToConstant: 40),
            
            streakDayLabel.topAnchor.constraint(equalTo: averageWorkTimeLabel.bottomAnchor, constant: 10),
            streakDayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            streakDayLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            streakDayLabel.heightAnchor.constraint(equalToConstant: 40),
            
            streakView.topAnchor.constraint(equalTo: streakDayLabel.bottomAnchor, constant: 30),
            streakView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            streakView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            streakView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            timeLabel.topAnchor.constraint(equalTo: streakView.topAnchor, constant: 10),
            timeLabel.centerXAnchor.constraint(equalTo: streakView.centerXAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: 100),
            
            leftTimeButton.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            leftTimeButton.leadingAnchor.constraint(equalTo: streakView.leadingAnchor, constant: 10),
            
            rightTimeButton.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            rightTimeButton.trailingAnchor.constraint(equalTo: streakView.trailingAnchor, constant: -10),
            
            lineView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
            lineView.leadingAnchor.constraint(equalTo: streakView.leadingAnchor, constant: 10),
            lineView.trailingAnchor.constraint(equalTo: streakView.trailingAnchor, constant: -10),
            lineView.heightAnchor.constraint(equalToConstant: 2),
            
            dayLabel.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 5),
            dayLabel.leadingAnchor.constraint(equalTo: streakView.leadingAnchor, constant: 5),
            dayLabel.trailingAnchor.constraint(equalTo: streakView.trailingAnchor, constant: -5),
        
            
            collectionView.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: streakView.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: streakView.trailingAnchor, constant: -10),
            
            collectionView.bottomAnchor.constraint(equalTo: streakView.bottomAnchor, constant: -10),
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DayCell.self, forCellWithReuseIdentifier: "DayCell")
    }
    
    @objc private func leftTimeButtonTapped() {
        // zaman geri
    }
    
    @objc private func rightTimeButtonTapped() {
        // zaman ileri
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as? DayCell else {
            return UICollectionViewCell()
        }
        cell.configure(isActive: true, isStreak: indexPath.item % 5 == 0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 17
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 21
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 28, height: 28)
    }
}


#Preview("ProfileViewController"){
    ProfileViewController()
}

