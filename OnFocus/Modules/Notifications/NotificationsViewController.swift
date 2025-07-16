//
//  NotificationsViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 22.04.2025.
//

import UIKit

protocol NotificationsViewInterface: AnyObject {
    func reloadData()
    func showMessage(_ text: String, type: MessageType)
    func setNoNotificationsLabel(hidden: Bool)
    func navigateToProfileDetail(userId: String)
}

final class NotificationsViewController: UIViewController {
    
    private var viewModel: NotificationsViewModelInterface
    
    init(viewModel: NotificationsViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.view = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: view.frame.width * 0.9, height: 70)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(NotificationsCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    private lazy var noNotificationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notifications Yet"
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        viewModel.viewDidLoad()
    }
    
    private func setupView(){
        view.backgroundColor = UIColor(hex: Constants.Colors.lightPeach)
        view.addSubview(collectionView)
        view.addSubview(noNotificationsLabel)
        
        navigationController?.navigationBar.tintColor = UIColor(hex: Constants.Colors.darkGray)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            noNotificationsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noNotificationsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension NotificationsViewController: NotificationsViewInterface {
    func navigateToProfileDetail(userId: String) {
        navigationController?.pushViewController(ProfileViewController(viewModel: ProfileViewModel(profileService: DIContainer.shared.resolve(), friendsService: DIContainer.shared.resolve(), presenceService: DIContainer.shared.resolve(), userId: userId)), animated: true)
    }
    
    func setNoNotificationsLabel(hidden: Bool) {
        noNotificationsLabel.isHidden = hidden
    }
    
    func showMessage(_ text: String, type: MessageType) {
        showAlert(text, type: type)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

extension NotificationsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? NotificationsCollectionViewCell else {
            return UICollectionViewCell()
        }

        let notification = viewModel.notification(at: indexPath.item)
        cell.configure(with: notification, at: indexPath, delegate: self)
        return cell
    }
}

extension NotificationsViewController: NotificationsCellDelegate {
    func didTapProfileImage(at indexPath: IndexPath) {
        viewModel.didTapProfileImage(at: indexPath)
    }
    
    
    func didTapAccept(at indexPath: IndexPath) {
        viewModel.acceptNotification(at: indexPath.item)
    }

    func didTapDecline(at indexPath: IndexPath) {
        viewModel.declineNotification(at: indexPath.item)
    }
}
