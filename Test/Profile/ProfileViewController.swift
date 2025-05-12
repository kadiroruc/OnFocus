//
//  ProfileViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 11.04.2025.
//

import UIKit
import FSCalendar

class ProfileViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
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
    
    private let calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.appearance.titleDefaultColor = UIColor(hex: "333333")
        calendar.appearance.todayColor = .clear
        calendar.appearance.titleTodayColor = UIColor(hex: "333333")
        calendar.appearance.selectionColor = UIColor(hex: "#70C1B3")
        
        calendar.appearance.headerDateFormat = "MMMM yyyy"
        calendar.appearance.headerTitleColor = UIColor(hex: "#333333")
        calendar.appearance.weekdayTextColor = .gray
        calendar.backgroundColor = UIColor(hex: "#FEF6F0")
        calendar.layer.cornerRadius = 20
        
        
        return calendar
    }()
    
    var streakDates: [Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let rawDates = [
            "2025-05-01",
            "2025-05-02",
            "2025-05-04",
            "2025-05-05",
            "2025-05-06"
        ].compactMap { formatter.date(from: $0) }

        streakDates = getStreakDays(from: rawDates)
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
    
    
    
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//
//    }
//    
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
//        
//        if streakDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
//            return .systemGreen
//        }
//        return nil
//    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! StreakCalendarCell

        guard position == .current else { return cell }
        
        let calendar = Calendar.current

        cell.isStreak = streakDates.contains { calendar.isDate($0, inSameDayAs: date) }
        
        if cell.isStreak {
            let previous = calendar.date(byAdding: .day, value: -1, to: date)!
            let next = calendar.date(byAdding: .day, value: 1, to: date)!
            
            cell.isLeftConnected = streakDates.contains { calendar.isDate($0, inSameDayAs: previous) }
            cell.isRightConnected = streakDates.contains { calendar.isDate($0, inSameDayAs: next) }
        }

        return cell
    }
    
    func getStreakDays(from dates: [Date]) -> [Date] {
        let sortedDates = dates.sorted()
        var streak: [Date] = []
        
        for i in 1..<sortedDates.count {
            let previous = sortedDates[i - 1]
            let current = sortedDates[i]
            let diff = Calendar.current.dateComponents([.day], from: previous, to: current).day!
            
            if diff == 1 {
                if !streak.contains(previous) {
                    streak.append(previous)
                }
                streak.append(current)
            }
        }
        
        return streak
    }
    
}


#Preview("ProfileViewController"){
    ProfileViewController()
}

