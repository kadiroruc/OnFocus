//
//  ViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 5.02.2025.
//

//
//  HomeViewController.swift
//  Test
//

import UIKit

protocol HomeViewInterface: AnyObject {
    func updateCountdownLabel(minutes: Int, seconds: Int)
    func startCircularAnimation(duration: TimeInterval)
    func pauseCircularAnimation()
    func resumeCircularAnimation()
    func updatePlayButton(isPaused: Bool)
}

final class HomeViewController: UIViewController {

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 70, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: "333333", alpha: 1)
        label.textAlignment = .center
        return label
    }()

    private let listCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.itemSize = CGSize(width: 50, height: 50)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 52, weight: .bold)
        let image = UIImage(systemName: "play", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(hex: "333333", alpha: 1)
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 23, weight: .regular)
        let image = UIImage(systemName: "xmark.circle", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(hex: "333333", alpha: 1)
        return button
    }()
    
    private let onlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor(hex: "444444", alpha: 1)
        label.textAlignment = .center
        return label
    }()

    private let sessionsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: "444444", alpha: 1)
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private let circleContainer : UIView = {
        let circleContainer = UIView()
        circleContainer.translatesAutoresizingMaskIntoConstraints = false
        return circleContainer
    }()

    private let workingLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 13
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor(hex: "#FF8A5C", alpha: 1)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    

    private lazy var viewModel = HomeViewModel()
    private var circleLayer = CAShapeLayer()
    private var movingCircle = UIView()
    private var isCirclePathCreated = false

    var pausedTime: CFTimeInterval = 0
    private var isContainerFullScreen = false

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
        setupUI()
        setupLayout()
        setupCircleContainerTapGesture()

        
        onlineLabel.text = "13423 Online"
        sessionsLabel.text = "1 of 4 Session"
        workingLabel.text = "10/58 Working"
    }

    private func setupUI() {
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        listCollectionView.register(HomePersonCollectionViewCell.self, forCellWithReuseIdentifier: Constants.CellIdentifiers.personCell)
        
        
        let settingsBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(gearButtonTapped))
        settingsBarButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = settingsBarButtonItem
        
        view.addSubview(timeLabel)
        view.addSubview(listCollectionView)
        circleContainer.addSubview(playButton)
        view.addSubview(cancelButton)
        view.addSubview(sessionsLabel)
        view.addSubview(circleContainer)
        view.addSubview(workingLabel)
        view.addSubview(onlineLabel)

        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
            
            if !isCirclePathCreated {
                createCircularPath()
                createMovingCircle()
                isCirclePathCreated = true
            }
        
        view.setGradientBackground(colors: [UIColor(hex: "#FEF6F0"), .white])
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            onlineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            onlineLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            onlineLabel.widthAnchor.constraint(equalToConstant: 120),
            onlineLabel.heightAnchor.constraint(equalToConstant: 20),
            
            sessionsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sessionsLabel.topAnchor.constraint(equalTo: onlineLabel.bottomAnchor, constant: 80),
            sessionsLabel.widthAnchor.constraint(equalToConstant: 120),
            sessionsLabel.heightAnchor.constraint(equalToConstant: 20),
            
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: sessionsLabel.bottomAnchor, constant: 20),
            timeLabel.widthAnchor.constraint(equalToConstant: 210),
            timeLabel.heightAnchor.constraint(equalToConstant: 60),
            
            circleContainer.centerXAnchor.constraint(equalTo: timeLabel.centerXAnchor),
            circleContainer.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            circleContainer.widthAnchor.constraint(equalToConstant: 260),
            circleContainer.heightAnchor.constraint(equalTo: circleContainer.widthAnchor),

            playButton.centerXAnchor.constraint(equalTo: circleContainer.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: circleContainer.centerYAnchor,constant: 75),
            playButton.widthAnchor.constraint(equalToConstant: 52),
            playButton.heightAnchor.constraint(equalToConstant: 52),

            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
            cancelButton.topAnchor.constraint(equalTo: circleContainer.topAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 38),
            cancelButton.heightAnchor.constraint(equalToConstant: 38),

            workingLabel.topAnchor.constraint(equalTo: circleContainer.bottomAnchor, constant: 50),
            workingLabel.centerXAnchor.constraint(equalTo:view.centerXAnchor),
            workingLabel.heightAnchor.constraint(equalToConstant: 30),
            workingLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),

            listCollectionView.topAnchor.constraint(equalTo: workingLabel.bottomAnchor, constant: 10),
            listCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            listCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            listCollectionView.heightAnchor.constraint(equalToConstant: 270)
        ])
    }

    private func createCircularPath() {
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: 130, y: 130),
            radius: 130,
            startAngle: -CGFloat.pi / 2,
            endAngle: 1.5 * CGFloat.pi,
            clockwise: true
        )

        circleLayer.path = circularPath.cgPath
        circleLayer.strokeColor = UIColor(hex: "#FF8A5C", alpha: 1).cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 12
        circleLayer.strokeEnd = 1


        circleContainer.layer.addSublayer(circleLayer)

    }

    private func createMovingCircle() {
        let centerPoint = CGPoint(x: 130, y: 130)
        movingCircle.frame = CGRect(x: centerPoint.x - 14, y: centerPoint.y - 130 - 14, width: 28, height: 28)
        movingCircle.layer.cornerRadius = 14
        movingCircle.backgroundColor = .white
        movingCircle.layer.borderWidth = 5
        movingCircle.layer.borderColor = UIColor(hex: "#333333", alpha: 1).cgColor
        circleContainer.addSubview(movingCircle)
    }

    @objc private func playButtonTapped() {
        viewModel.toggleCountdown()
    }

    @objc private func settingsButtonTapped() {
        viewModel.settingsButtonTapped()
    }
    
    @objc private func gearButtonTapped() {
        //viewModel.gearButtonTapped()
        navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
}

extension HomeViewController: HomeViewInterface {
    func updateCountdownLabel(minutes: Int, seconds: Int) {
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    func startCircularAnimation(duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 0
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        circleLayer.add(animation, forKey: "circleAnimation")

        let circularPath = UIBezierPath(arcCenter: CGPoint(x: 130, y: 130),
                                        radius: 130,
                                        startAngle: -CGFloat.pi/2,
                                        endAngle: -CGFloat.pi / 2 - 2 * CGFloat.pi,
                                        clockwise: false)

        let moveAnimation = CAKeyframeAnimation(keyPath: "position")
        moveAnimation.path = circularPath.cgPath
        moveAnimation.duration = duration
        moveAnimation.fillMode = .forwards
        moveAnimation.isRemovedOnCompletion = false

        movingCircle.layer.add(moveAnimation, forKey: "movingCircleAnimation")
        viewModel.animationRunning = true
    }

    func pauseCircularAnimation() {
        let pausedTime = movingCircle.layer.convertTime(CACurrentMediaTime(), from: nil)
        movingCircle.layer.speed = 0.0
        movingCircle.layer.timeOffset = pausedTime
        circleLayer.speed = 0.0
        circleLayer.timeOffset = pausedTime
    }

    func resumeCircularAnimation() {
        let pausedTime = movingCircle.layer.timeOffset
        movingCircle.layer.speed = 1.0
        movingCircle.layer.timeOffset = 0.0
        movingCircle.layer.beginTime = 0.0
        let timeSincePause = movingCircle.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        movingCircle.layer.beginTime = timeSincePause

        circleLayer.speed = 1.0
        circleLayer.timeOffset = 0.0
        circleLayer.beginTime = timeSincePause
    }

    func updatePlayButton(isPaused: Bool) {

        let buttonImage = isPaused ?         UIImage(systemName: "play", withConfiguration: UIImage.SymbolConfiguration(pointSize: 52, weight: .bold)) :         UIImage(systemName: "pause", withConfiguration: UIImage.SymbolConfiguration(pointSize: 52, weight: .bold))
        playButton.setImage(buttonImage, for: .normal)
    }
    
    private func setupCircleContainerTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(circleContainerTapped(_:)))
        
        circleContainer.isUserInteractionEnabled = true
        circleContainer.addGestureRecognizer(tapGesture)
    }

    @objc private func circleContainerTapped(_ gesture: UITapGestureRecognizer) {
        let locationInLabel = gesture.location(in: timeLabel)
        
        
        if timeLabel.bounds.contains(locationInLabel) {
            listCollectionView.isHidden.toggle()
            if isContainerFullScreen{
                
                let timeLabelConstraints = timeLabel.allAttachedConstraints()
                NSLayoutConstraint.deactivate(timeLabelConstraints)

                let collectionViewConstraints = listCollectionView.allAttachedConstraints()
                NSLayoutConstraint.deactivate(collectionViewConstraints)

                let playButtonConstraints = playButton.allAttachedConstraints()
                NSLayoutConstraint.deactivate(playButtonConstraints)

                let cancelButtonConstraints = cancelButton.allAttachedConstraints()
                NSLayoutConstraint.deactivate(cancelButtonConstraints)

                let onlineLabelConstraints = onlineLabel.allAttachedConstraints()
                NSLayoutConstraint.deactivate(onlineLabelConstraints)

                let sessionsLabelConstraints = sessionsLabel.allAttachedConstraints()
                NSLayoutConstraint.deactivate(sessionsLabelConstraints)

                let circleContainerConstraints = circleContainer.allAttachedConstraints()
                NSLayoutConstraint.deactivate(circleContainerConstraints)

                let workingLabelConstraints = workingLabel.allAttachedConstraints()
                NSLayoutConstraint.deactivate(workingLabelConstraints)
                
                
                setupLayout()
                
            }else{
                NSLayoutConstraint.activate([
                    
                    sessionsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -60),
                    
                    timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    timeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    onlineLabel.centerYAnchor.constraint(equalTo: circleContainer.centerYAnchor,constant: -170),
                    
                    cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
                    cancelButton.topAnchor.constraint(equalTo: circleContainer.topAnchor),
                    cancelButton.widthAnchor.constraint(equalToConstant: 38),
                    cancelButton.heightAnchor.constraint(equalToConstant: 38),

                ])
                
            }
            
            isContainerFullScreen.toggle()

            
            UIView.animate(withDuration: 0.3) {
                print("aa")
                self.view.layoutIfNeeded()
            }
        }
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifiers.personCell, for: indexPath) as! HomePersonCollectionViewCell
        cell.layer.cornerRadius = 25
        cell.clipsToBounds = true
        cell.layer.borderColor = UIColor(hex: "#70C1B3").cgColor
        cell.layer.borderWidth = 5
        cell.contentMode = .scaleAspectFit
//        cell.profileImageView.image = UIImage(systemName: "person")
        return cell
    }
}

#Preview("HomeViewController"){
    HomeViewController()
}

