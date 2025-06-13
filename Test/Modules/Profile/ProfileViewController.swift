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
    func showMessage(_ text: String, type: MessageType)
    func updateStreakCalendar()
    func updateNickname(_ nickname: String)
    func updateTotalWorkTime(_ time: String)
    func updateStreakDayLabel(_ count: Int)
    func setAddFriendButtonHidden(_ hidden: Bool)
    func setMenuButtonHidden(_ hidden: Bool)
    func navigateToLogin()
    func showLoading(_ isLoading: Bool)
    func configureAddFriendButton(_ status: String?)
    func navigateToFillProfile()
}

class ProfileViewController: UIViewController {
    private var viewModel: ProfileViewModelInterface
    private var friendButtonStatus: String?
    
    private let friendBarButtonItem : UIBarButtonItem = {
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
    
    private let totalWorkTimeLabel: UILabel = {
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
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
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
        view.addSubview(totalWorkTimeLabel)
        view.addSubview(streakDayLabel)
        view.addSubview(activityIndicator)
        
        view.addSubview(calendar)
        calendar.register(StreakCalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.delegate = self
        calendar.dataSource = self
        
        
        menuBarButtonItem.target = self
        menuBarButtonItem.action = #selector(menuBarButtonItemTapped)
        
        friendBarButtonItem.target = self
        friendBarButtonItem.action = #selector(friendBarButtonItemTapped)
        
        navigationItem.rightBarButtonItems = [menuBarButtonItem, friendBarButtonItem]
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
            
            totalWorkTimeLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 30),
            totalWorkTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            totalWorkTimeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            totalWorkTimeLabel.heightAnchor.constraint(equalToConstant: 40),
            
            streakDayLabel.topAnchor.constraint(equalTo: totalWorkTimeLabel.bottomAnchor, constant: 10),
            streakDayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            streakDayLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            streakDayLabel.heightAnchor.constraint(equalToConstant: 40),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -20),
            activityIndicator.widthAnchor.constraint(equalToConstant: 40),
            activityIndicator.heightAnchor.constraint(equalToConstant: 40)
           
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
    @objc private func menuBarButtonItemTapped() {
        let alert = UIAlertController(title: "Menu", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Change Profile Photo", style: .default, handler: { _ in
            self.showPicker()
        }))

        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            self.viewModel.signOut()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func friendBarButtonItemTapped() {
        if let status = friendButtonStatus{
            switch status{
            case Constants.Firebase.rejected:
                viewModel.addFriendTapped()
                
            case Constants.Firebase.pending:
                let alert = UIAlertController(title: "Friend Request Pending", message: "Do you want to cancel the request?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel Request", style: .destructive, handler: { _ in
                    self.viewModel.cancelFriendRequest()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alert, animated: true)
                
                
            case Constants.Firebase.accepted:
                let alert = UIAlertController(title: "Do you want to remove your friend?", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel Request", style: .destructive, handler: { _ in
                    self.viewModel.cancelFriendRequest()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alert, animated: true)
                
            default:
                viewModel.addFriendTapped()
            }
        }else{
            viewModel.addFriendTapped()
        }
        
    }
    
    private func showPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

}

// MARK: - ProfileViewInterface
extension ProfileViewController: ProfileViewInterface {
    func navigateToFillProfile() {
        let fillProfileVC = DIContainer.shared.makeFillProfileViewController()
        fillProfileVC.modalPresentationStyle = .fullScreen
        present(fillProfileVC, animated: true, completion: nil)
    }
    
    func configureAddFriendButton(_ status: String?) {
        if let status = status{
            friendButtonStatus = status
            switch status {
            case Constants.Firebase.pending:
                friendBarButtonItem.image = UIImage(systemName: Constants.Icons.personBadgeClockFill)?.withTintColor(UIColor(hex: Constants.Colors.darkGray, alpha: 1), renderingMode: .alwaysOriginal)
                
            case Constants.Firebase.accepted:
                friendBarButtonItem.image = UIImage(systemName: Constants.Icons.personFillCheckmark)?.withTintColor(UIColor(hex: Constants.Colors.mintGreen, alpha: 1), renderingMode: .alwaysOriginal)
            case Constants.Firebase.rejected:
                friendBarButtonItem.image = UIImage(systemName: Constants.Icons.personBadgePlus)?.withTintColor(UIColor(hex: Constants.Colors.darkGray, alpha: 1), renderingMode: .alwaysOriginal)
            default:
                friendBarButtonItem.image = UIImage(systemName: Constants.Icons.personBadgePlus)?.withTintColor(UIColor(hex: Constants.Colors.darkGray, alpha: 1), renderingMode: .alwaysOriginal)

            }
        }
    }
    
    func showLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }
    
    func setMenuButtonHidden(_ hidden: Bool) {
        menuBarButtonItem.isHidden = hidden
    }
    
    func navigateToLogin() {
        let loginVC = DIContainer.shared.makeLoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true, completion: nil)
    }
    
    func setAddFriendButtonHidden(_ hidden: Bool) {
        friendBarButtonItem.isHidden = hidden
    }
    
    func updateProfileImage(with url: URL) {
        profileImageView.kf.setImage(with: url)
    }


    func showMessage(_ text: String, type: MessageType) {
        showAlert(text, type: type)
    }

    func updateStreakCalendar() {
        calendar.reloadData()
    }

    func updateNickname(_ nickname: String) {
        nicknameLabel.text = nickname
    }

    func updateTotalWorkTime(_ time: String) {
        totalWorkTimeLabel.text = time
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

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let editedImage = info[.editedImage] as? UIImage {
            profileImageView.image = editedImage
            viewModel.setSelectedImage(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageView.image = originalImage
            viewModel.setSelectedImage(originalImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


#Preview(""){
    return UINavigationController(rootViewController: DIContainer.shared.makeProfileViewController())
}
