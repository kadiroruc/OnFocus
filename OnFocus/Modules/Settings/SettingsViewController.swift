//
//  SettingsViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 9.03.2025.
//

import UIKit

protocol SettingsViewInterface: AnyObject {
    func changeTimerMode(timeKeeperMode: Bool)
    func showMessage(_ text: String, type: MessageType, isCancelEnabled:Bool,  _ completion: (() -> Void)?)
    func navigateToLogin()
    func showLoading(_ isLoading: Bool)
}

protocol SettingsCoordinatorDelegate: AnyObject {
    func didChangeTimerMode(timeKeeperMode: Bool)
}

class SettingsViewController: UIViewController {
    
    private var viewModel: SettingsViewModelInterface
    
    weak var delegate: SettingsCoordinatorDelegate?
    
    init(viewModel: SettingsViewModelInterface) {
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
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: view.frame.width * 0.95, height: 50)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(SettingsCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = UIColor(hex: Constants.Colors.darkGray, alpha: 1)
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        title = L10n.Settings.title
        view.backgroundColor = UIColor(hex: Constants.Colors.lightPeach)
        
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 24),
            activityIndicator.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}

extension SettingsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfSettings()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SettingsCollectionViewCell
        
        cell.configureCell(settingsModel: viewModel.getSetting(at: indexPath.item))
        cell.switchAction = { [weak self] isOn in
            guard let self = self else { return }
            
            self.viewModel.tappedSwitchAction(for: indexPath.item, isOn: isOn)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width * 0.9, height: 50)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.tappedSetting(at: indexPath.item)
    }
    
}

extension SettingsViewController: SettingsViewInterface{
    func showLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func navigateToLogin() {
        guard let scene = view.window?.windowScene else { return }
        
        let loginViewController: LoginViewController = DIContainer.shared.resolve()
        
        if let delegate = scene.delegate as? SceneDelegate,
           let window = delegate.window {
            
            UIView.transition(with: window, duration: 0.4, options: .transitionFlipFromRight) {
                window.rootViewController = loginViewController
            }
        }
    }
    
    func showMessage(_ text: String, type: MessageType, isCancelEnabled:Bool, _ completion: (() -> Void)?) {
        showAlert(text, type: type, isCancelEnabled, completion: completion)
    }
    
    func changeTimerMode(timeKeeperMode: Bool) {
        delegate?.didChangeTimerMode(timeKeeperMode: timeKeeperMode)
    }
    
}


//#Preview("SettingsViewController"){
//    SettingsViewController()
//}
