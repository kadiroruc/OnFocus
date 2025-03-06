//
//  ViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 5.02.2025.
//

import UIKit

protocol HomeViewInterface: AnyObject, SeguePerformable {
    func updateCountdownLabel(minutes: Int, seconds: Int)
    func startCircularAnimation(duration: TimeInterval)
    func pauseCircularAnimation()
    func resumeCircularAnimation()
    func updatePlayButton(isPaused: Bool)
}

final class HomeViewController: UIViewController {
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var countdownView: UIView!
    @IBOutlet var listCollectionView: UICollectionView!
    @IBOutlet var playButton: UIButton!
    
    private lazy var viewModel = HomeViewModel()
    private var circleLayer = CAShapeLayer()
    private var movingCircle = UIView()
    
    var pausedTime: CFTimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        createCircularPath()
        createMovingCircle()
    }
    
    private func createCircularPath() {
        let centerPoint = timeLabel.center
        let circularPath = UIBezierPath(arcCenter: centerPoint, radius: 130, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        circleLayer.path = circularPath.cgPath
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 8
        circleLayer.strokeEnd = 1
        view.layer.addSublayer(circleLayer)
    }
    
    private func createMovingCircle() {
        let centerPoint = timeLabel.center
        movingCircle.frame = CGRect(x: centerPoint.x - 10, y: centerPoint.y - 130 - 10, width: 20, height: 20)
        movingCircle.layer.cornerRadius = 10
        movingCircle.backgroundColor = .systemIndigo
        movingCircle.layer.borderWidth = 3
        movingCircle.layer.borderColor = UIColor.white.cgColor
        view.addSubview(movingCircle)
    }
    
    
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        viewModel.toggleCountdown()
        
    }
}

extension HomeViewController: HomeViewInterface{
    func updateCountdownLabel(minutes: Int, seconds: Int) {
        timeLabel.text = String(format: "%02d.%02d", minutes, seconds)
    }
    
    func startCircularAnimation(duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 0
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        circleLayer.add(animation, forKey: "circleAnimation")
        
        //small circle
        let centerPoint = timeLabel.center
        let circularPath = UIBezierPath(arcCenter: centerPoint,
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

        // Küçük daire için duraklat
        movingCircle.layer.speed = 0.0
        movingCircle.layer.timeOffset = pausedTime
        
        // Büyük daire (çizgi) için duraklat
        circleLayer.speed = 0.0
        circleLayer.timeOffset = pausedTime
        
    }
    
    func resumeCircularAnimation() {
        
        let pausedTime = movingCircle.layer.timeOffset
        
        // Küçük daire için devam ettir
        movingCircle.layer.speed = 1.0
        movingCircle.layer.timeOffset = 0.0
        movingCircle.layer.beginTime = 0.0
        let timeSincePause = movingCircle.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        movingCircle.layer.beginTime = timeSincePause

        // Büyük daire (çizgi) için devam ettir
        circleLayer.speed = 1.0
        circleLayer.timeOffset = 0.0
        circleLayer.beginTime = timeSincePause

    }
    
    func updatePlayButton(isPaused: Bool) {
        let buttonImage = isPaused ? UIImage(systemName: "play") : UIImage(systemName: "pause")
        playButton.setImage(buttonImage, for: .normal)
    }
}
