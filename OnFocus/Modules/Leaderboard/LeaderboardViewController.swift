//
//  LeaderboardViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 20.04.2025.
//

import UIKit

protocol LeaderboardViewInterface: AnyObject{
    func showTopThreeProfiles(_ topProfiles: [ProfileModel])
    func showOtherProfiles(_ otherProfiles: [ProfileModel])
    func showError(message: String)
    func showLoading(_ isLoading: Bool)
    func updateStateRankLabel(_ rank: String)
    func updateStateLabel(_ percentile: Int)
    
}

class LeaderboardViewController: UIViewController {
    private var viewModel: LeaderboardViewModelInterface
    
    private let sheetVC = BottomSheetViewController()
    
    
    private let stateView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: Constants.Colors.babyBlue, alpha: 1)
        return view
    }()
    
    private let stateRankLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        label.font = .systemFont(ofSize: 20)
        label.backgroundColor = UIColor(hex: Constants.Colors.lightOrange, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private let stateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let firstProfileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 35
        iv.backgroundColor = .black
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .clear
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: Constants.Icons.personCircle)?.withTintColor(UIColor(hex: Constants.Colors.darkGray), renderingMode: .alwaysOriginal)
        return iv
    }()
    
    private let firstProfileLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = UIColor(hex: Constants.Colors.darkGray, alpha: 1)
        label.text = ""
        return label
    }()
    
    private let firstProfileTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.backgroundColor = UIColor(hex: Constants.Colors.softOrange, alpha: 1)
        label.textColor = .white
        label.text = L10n.Leaderboard.zeroTime
        return label
    }()
    
    private let crownIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "crown")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let secondProfileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 35
        iv.backgroundColor = .black
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .clear
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: Constants.Icons.personCircle)?.withTintColor(UIColor(hex: Constants.Colors.darkGray), renderingMode: .alwaysOriginal)
        return iv
    }()
    
    private let secondProfileLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = UIColor(hex: Constants.Colors.darkGray, alpha: 1)
        label.text = L10n.Leaderboard.exampleUser
        return label
    }()
    
    private let secondProfileTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.backgroundColor = UIColor(hex: Constants.Colors.softOrange, alpha: 1)
        label.textColor = .white
        label.text = L10n.Leaderboard.zeroTime
        return label
    }()
    
    private let thirdProfileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 35
        iv.backgroundColor = .black
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .clear
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: Constants.Icons.personCircle)?.withTintColor(UIColor(hex: Constants.Colors.darkGray), renderingMode: .alwaysOriginal)
        return iv
    }()
    
    private let thirdProfileLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = UIColor(hex: Constants.Colors.darkGray, alpha: 1)
        label.text = L10n.Leaderboard.exampleUser
        return label
    }()
    
    private let thirdProfileTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.backgroundColor = UIColor(hex: Constants.Colors.softOrange, alpha: 1)
        label.textColor = .white
        label.text = L10n.Leaderboard.zeroTime
        return label
    }()
    
    private let podiumIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "podium")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }()
    
    //MARK: - Init
    init(viewModel: LeaderboardViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.view = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupBottomSheet()
        
        viewModel.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.setGradientBackground(colors: [UIColor(hex: Constants.Colors.lightPeach), .white])
    }
    
    func setupView(){
        tabBarController?.tabBar.backgroundColor = .white
        let searchBarButtonItem = UIBarButtonItem(image: UIImage(systemName: Constants.Icons.magnifyingglassCircleFill), style: .plain, target: self, action: #selector(searchBarButtonItemTapped))
        searchBarButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = searchBarButtonItem
        
        
        view.addSubview(stateView)
        stateView.addSubview(stateRankLabel)
        stateView.addSubview(stateLabel)
        view.addSubview(firstProfileImageView)
        view.addSubview(firstProfileLabel)
        view.addSubview(firstProfileTimeLabel)
        view.addSubview(crownIconImageView)
        view.addSubview(secondProfileImageView)
        view.addSubview(secondProfileLabel)
        view.addSubview(secondProfileTimeLabel)
        view.addSubview(thirdProfileImageView)
        view.addSubview(thirdProfileLabel)
        view.addSubview(thirdProfileTimeLabel)
        view.addSubview(podiumIconImageView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            
            stateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
            stateView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1),
            
            stateRankLabel.centerYAnchor.constraint(equalTo: stateView.centerYAnchor),
            stateRankLabel.leadingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: 20),
            stateRankLabel.heightAnchor.constraint(equalToConstant: 50),
            stateRankLabel.widthAnchor.constraint(equalToConstant: 50),
            
            stateLabel.centerYAnchor.constraint(equalTo: stateView.centerYAnchor),
            stateLabel.leadingAnchor.constraint(equalTo: stateRankLabel.trailingAnchor, constant: 20),
            stateLabel.trailingAnchor.constraint(equalTo: stateView.trailingAnchor, constant: -20),
            
            
            firstProfileImageView.topAnchor.constraint(equalTo: stateView.bottomAnchor, constant: 30),
            firstProfileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstProfileImageView.widthAnchor.constraint(equalToConstant: 70),
            firstProfileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            crownIconImageView.topAnchor.constraint(equalTo: firstProfileImageView.topAnchor,constant: -25),
            crownIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            crownIconImageView.widthAnchor.constraint(equalToConstant: 50),
            crownIconImageView.heightAnchor.constraint(equalToConstant: 50),
            
            
            firstProfileLabel.topAnchor.constraint(equalTo: firstProfileImageView.bottomAnchor, constant: 15),
            firstProfileLabel.centerXAnchor.constraint(equalTo: firstProfileImageView.centerXAnchor),
            firstProfileLabel.widthAnchor.constraint(equalToConstant: 100),
            firstProfileLabel.heightAnchor.constraint(equalToConstant: 45),
            
            firstProfileTimeLabel.topAnchor.constraint(equalTo: firstProfileLabel.bottomAnchor, constant: 10),
            firstProfileTimeLabel.centerXAnchor.constraint(equalTo: firstProfileLabel.centerXAnchor),
            firstProfileTimeLabel.widthAnchor.constraint(equalToConstant: 70),
            firstProfileTimeLabel.heightAnchor.constraint(equalToConstant: 40),
            
            secondProfileImageView.topAnchor.constraint(equalTo: firstProfileImageView.centerYAnchor),
            secondProfileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 40),
            secondProfileImageView.widthAnchor.constraint(equalToConstant: 70),
            secondProfileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            secondProfileLabel.topAnchor.constraint(equalTo: secondProfileImageView.bottomAnchor, constant: 15),
            secondProfileLabel.centerXAnchor.constraint(equalTo: secondProfileImageView.centerXAnchor),
            secondProfileLabel.widthAnchor.constraint(equalToConstant: 100),
            secondProfileLabel.heightAnchor.constraint(equalToConstant: 45),
            
            secondProfileTimeLabel.topAnchor.constraint(equalTo: secondProfileLabel.bottomAnchor, constant: 10),
            secondProfileTimeLabel.centerXAnchor.constraint(equalTo: secondProfileLabel.centerXAnchor),
            secondProfileTimeLabel.widthAnchor.constraint(equalToConstant: 70),
            secondProfileTimeLabel.heightAnchor.constraint(equalToConstant: 40),
            
            thirdProfileImageView.topAnchor.constraint(equalTo: firstProfileImageView.bottomAnchor),
            thirdProfileImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -40),
            thirdProfileImageView.widthAnchor.constraint(equalToConstant: 70),
            thirdProfileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            thirdProfileLabel.topAnchor.constraint(equalTo: thirdProfileImageView.bottomAnchor, constant: 15),
            thirdProfileLabel.centerXAnchor.constraint(equalTo: thirdProfileImageView.centerXAnchor),
            thirdProfileLabel.widthAnchor.constraint(equalToConstant: 100),
            thirdProfileLabel.heightAnchor.constraint(equalToConstant: 45),
            
            thirdProfileTimeLabel.topAnchor.constraint(equalTo: thirdProfileLabel.bottomAnchor, constant: 10),
            thirdProfileTimeLabel.centerXAnchor.constraint(equalTo: thirdProfileLabel.centerXAnchor),
            thirdProfileTimeLabel.widthAnchor.constraint(equalToConstant: 70),
            thirdProfileTimeLabel.heightAnchor.constraint(equalToConstant: 40),
            
            podiumIconImageView.topAnchor.constraint(equalTo: firstProfileTimeLabel.bottomAnchor, constant: 20),
            podiumIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            podiumIconImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            podiumIconImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            podiumIconImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -20),
            activityIndicator.widthAnchor.constraint(equalToConstant: 40),
            activityIndicator.heightAnchor.constraint(equalToConstant: 40)
            
            
            
        ])
    }


    
    @objc private func setupBottomSheet() {
        // Add as child
        addChild(sheetVC)
        view.addSubview(sheetVC.view)
        sheetVC.didMove(toParent: self)
        
        // Layout
        NSLayoutConstraint.activate([
            sheetVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10),
            sheetVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -10),
            sheetVC.view.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor),
            sheetVC.view.topAnchor.constraint(equalTo: podiumIconImageView.bottomAnchor, constant: -30)
        ])
    }
    
    @objc func searchBarButtonItemTapped(){
        let searchViewController: ProfileSearchViewController = DIContainer.shared.resolve()
        navigationController?.pushViewController(searchViewController, animated: true)
    }
}

extension LeaderboardViewController: LeaderboardViewInterface {
    func updateStateLabel(_ percentile: Int) {
        stateLabel.text = L10n.Leaderboard.stateLabel(percentile)
    }
    
    func updateStateRankLabel(_ rank: String) {
        stateRankLabel.text = L10n.Leaderboard.rankLabel(rank)
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
    
    func showTopThreeProfiles(_ topProfiles: [ProfileModel]) {
        if topProfiles.indices.contains(0) {
            firstProfileLabel.text = topProfiles[0].nickname
            firstProfileTimeLabel.text = topProfiles[0].totalWorkTimeFormatted
            if let imageUrl = topProfiles[0].profileImageURL {
                firstProfileImageView.kf.setImage(with: URL(string: imageUrl))
            } else {
                firstProfileImageView.image = UIImage(systemName: Constants.Icons.personCircle)?.withTintColor(UIColor(hex: Constants.Colors.darkGray), renderingMode: .alwaysOriginal)
            }
        }

        if topProfiles.indices.contains(1) {
            secondProfileLabel.text = topProfiles[1].nickname
            secondProfileTimeLabel.text = topProfiles[1].totalWorkTimeFormatted
            if let imageUrl = topProfiles[1].profileImageURL {
                secondProfileImageView.kf.setImage(with: URL(string: imageUrl))
            } else {
                secondProfileImageView.image = UIImage(systemName: Constants.Icons.personCircle)?.withTintColor(UIColor(hex: Constants.Colors.darkGray), renderingMode: .alwaysOriginal)
            }
        }

        if topProfiles.indices.contains(2) {
            thirdProfileLabel.text = topProfiles[2].nickname
            thirdProfileTimeLabel.text = topProfiles[2].totalWorkTimeFormatted
            if let imageUrl = topProfiles[2].profileImageURL {
                thirdProfileImageView.kf.setImage(with: URL(string: imageUrl))
            } else {
                thirdProfileImageView.image = UIImage(systemName: Constants.Icons.personCircle)?.withTintColor(UIColor(hex: Constants.Colors.darkGray), renderingMode: .alwaysOriginal)
            }
        }
    }
    
    func showOtherProfiles(_ otherProfiles: [ProfileModel]) {
        sheetVC.updateWithProfiles(otherProfiles)
    }
    
    func showError(message: String) {
        showAlert(message, type: .error)
    }
    
    
}


//#Preview("LeaderboardViewController"){
//    DIContainer.shared.makeLeaderboardViewController()
//}
