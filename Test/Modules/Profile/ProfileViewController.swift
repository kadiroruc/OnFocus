//
//  ProfileViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 11.04.2025.
//

import UIKit
import FSCalendar
import Kingfisher

protocol ProfileViewInterface: AnyObject {
    func updateProfileImage(with url: URL)
    func showError(_ message: String)
    func updateStreakCalendar()
    func updateNickname(_ nickname: String)
    func updateAverageWorkTime(_ time: String)
    func updateStreakDayLabel(_ count: Int)
    func setAddFriendButtonHidden(_ hidden: Bool)
}

class ProfileViewController: UIViewController {
    private let viewModel: ProfileViewModelInterface
    
    private let addFriendBarButtonItem : UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(systemName: Constants.Icons.personBadgePlus)?.withTintColor(UIColor(hex: Constants.Colors.darkGray, alpha: 1), renderingMode: .alwaysOriginal)
        return item
    }()
    
    private let menuBarButtonItem : UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(systemName: Constants.Icons.ellipsis)?.withTintColor(UIColor(hex: Constants.Colors.darkGray, alpha: 1), renderingMode: .alwaysOriginal)
        return item
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 60
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: Constants.Icons.personCircle)
        iv.tintColor = UIColor(hex: Constants.Colors.darkGray, alpha: 1)
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
        label.text = "Average Work Hour: "
        label.textColor = .white
        label.backgroundColor = UIColor(hex: Constants.Colors.mintGreen)
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let streakDayLabel: UILabel = {
        let label = UILabel()
        label.text = "Current Streak Day: "
        label.textColor = .white
        label.backgroundColor = UIColor(hex: Constants.Colors.softOrange)
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.appearance.titleDefaultColor = UIColor(hex: Constants.Colors.darkGray)
        calendar.appearance.todayColor = .clear
        calendar.appearance.titleTodayColor = UIColor(hex: Constants.Colors.darkGray)
        calendar.appearance.selectionColor = UIColor(hex: Constants.Colors.mintGreen)
        
        calendar.appearance.headerDateFormat = "MMMM yyyy"
        calendar.appearance.headerTitleColor = UIColor(hex: Constants.Colors.darkGray)
        calendar.appearance.weekdayTextColor = .gray
        calendar.backgroundColor = UIColor(hex: Constants.Colors.lightPeach)
        calendar.layer.cornerRadius = 20
        return calendar
    }()
    
    //MARK: - Initialization
    init(viewModel: ProfileViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.view = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        viewModel.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.setGradientBackground(colors: [UIColor(hex: Constants.Colors.lightPeach), .white])
    }
    private func setupViews() {
        view.addSubview(profileImageView)
        view.addSubview(nicknameLabel)
        view.addSubview(averageWorkTimeLabel)
        view.addSubview(streakDayLabel)
        
        view.addSubview(calendar)
        calendar.register(StreakCalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.delegate = self
        calendar.dataSource = self
        
        navigationItem.rightBarButtonItems = [menuBarButtonItem, addFriendBarButtonItem]
    }
    
    private func setupConstraints() {
        
        let streakCalendarConstraints = [
            calendar.topAnchor.constraint(equalTo: streakDayLabel.bottomAnchor, constant: 40),
            calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
            
            streakDayLabel.topAnchor.constraint(equalTo: averageWorkTimeLabel.bottomAnchor, constant: 10),
            streakDayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            streakDayLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            streakDayLabel.heightAnchor.constraint(equalToConstant: 40),
            
           
        ])
        
        if traitCollection.userInterfaceIdiom == .pad {
            
            NSLayoutConstraint.deactivate(streakCalendarConstraints)
            NSLayoutConstraint.activate([
                calendar.topAnchor.constraint(equalTo: streakDayLabel.bottomAnchor, constant: 80),
                calendar.leadingAnchor.constraint(equalTo: streakDayLabel.leadingAnchor),
                calendar.trailingAnchor.constraint(equalTo: streakDayLabel.trailingAnchor),
                calendar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
                
            ])

        }else{
            NSLayoutConstraint.activate(streakCalendarConstraints)
        }
    }

}

// MARK: - ProfileViewInterface
extension ProfileViewController: ProfileViewInterface {
    func setAddFriendButtonHidden(_ hidden: Bool) {
        addFriendBarButtonItem.isHidden = hidden
    }
    
    func updateProfileImage(with url: URL) {
        profileImageView.kf.setImage(with: url)
    }


    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func updateStreakCalendar() {
        calendar.reloadData()
    }

    func updateNickname(_ nickname: String) {
        nicknameLabel.text = nickname
    }

    func updateAverageWorkTime(_ time: String) {
        averageWorkTimeLabel.text = time
    }

    func updateStreakDayLabel(_ count: Int) {
        streakDayLabel.text = "Current Streak Day: \(count)"
    }
}

// MARK: - FSCalendar
extension ProfileViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! StreakCalendarCell
        guard position == .current else { return cell }

        
        cell.isStreak = viewModel.isDatePartOfStreak(date)
        cell.isLeftConnected = viewModel.isDateConnectedLeft(date)
        cell.isRightConnected = viewModel.isDateConnectedRight(date)


        return cell
    }
}


#Preview(""){
    return UINavigationController(rootViewController: ProfileModuleBuilder.build(userId: nil))
}
