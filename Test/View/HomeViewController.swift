//
//  ViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 5.02.2025.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var countdownView: UIView!
    var countdownMinutes = 0
    var countdownSeconds = 5
    var splitSeconds = 59
    
    var circleLayer = CAShapeLayer()
    var movingCircle = UIView() // Hareket eden daireyi burada tanımlıyoruz
    
    var countdownTimer: Timer?
    var circularCountdownTimeInterval : TimeInterval?
    
    var pausedTime: CFTimeInterval = 0
    var animationRunning = false
    
    @IBOutlet var listCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCountdownLabel()
        setupUI()
        
    }
    
    private func setupUI() {
        
        // Çizgi oluştur ve animasyon ekle
        createCircularPath()
        
        // Hareket eden daireyi oluştur
        createMovingCircle()
    }
    
    private func  createCircularPath() {
        let centerPoint = timeLabel.center
        let circularPath = UIBezierPath(arcCenter: centerPoint,
                                        radius: 130, // Yarıçap
                                        startAngle: -CGFloat.pi / 2, // Saat yönünde başlatmak için -pi/2
                                        endAngle: 1.5 * CGFloat.pi,   // Saat yönünde 1.5 pi (tam daire)
                                        clockwise: true) // Saat yönü
        
        circleLayer.path = circularPath.cgPath
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 8
        circleLayer.strokeEnd = 1 // Başlangıçta daire tamamen dolu
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
    
    // Geri sayım ve animasyonu senkronize eden fonksiyon
    private func startCircularCountdown(duration: TimeInterval) {
        // Çizgiyi boşaltma animasyonu
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 0
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        circleLayer.add(animation, forKey: "circleAnimation")
        
        // Küçük daireyi döndürme animasyonunu başlat
        animateMovingCircle(duration: duration)
        
        // Zamanlayıcıyı başlat
        if countdownTimer == nil {  // Zamanlayıcı zaten başlatılmadıysa başlat
            countdownTimer = Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        }
    }

    // Küçük dairenin animasyonunu başlatan fonksiyon
    private func animateMovingCircle(duration: TimeInterval) {
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
        animationRunning = true
    }

    // Durdurulduğunda animasyonu ve geri sayımı duraklatma fonksiyonu
    func pauseAnimation() {
        let pausedTime = movingCircle.layer.convertTime(CACurrentMediaTime(), from: nil)
        
        // Küçük daire için duraklat
        movingCircle.layer.speed = 0.0
        movingCircle.layer.timeOffset = pausedTime
        
        // Büyük daire (çizgi) için duraklat
        circleLayer.speed = 0.0
        circleLayer.timeOffset = pausedTime
        
        // Zamanlayıcıyı duraklat
        countdownTimer?.invalidate()
    }

    // Devam ettirildiğinde animasyonu ve geri sayımı yeniden başlatma fonksiyonu
    func resumeAnimation() {
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
        
        // Zamanlayıcıyı yeniden başlat
        countdownTimer = Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }

    @objc func updateCountdown() {
        if countdownMinutes > 0 || countdownSeconds > 0 || splitSeconds > 0 {
            if splitSeconds == 0 {
                if countdownSeconds == 0 {
                    if countdownMinutes > 0 {
                        countdownMinutes -= 1
                        countdownSeconds = 59
                    }
                } else {
                    countdownSeconds -= 1
                }
                splitSeconds = 59 // Salise sıfırlanır, 60'tan 1'e kadar döner
            } else {
                splitSeconds -= 1
            }
            updateCountdownLabel()
        } else {
            countdownTimer?.invalidate() // Geriye sayma bitince timer'ı durdur
        }
    }

    // Geri sayım etiketini güncelleyen fonksiyon
    func updateCountdownLabel() {
        // Dakikayı ve saniyeyi label'a yaz
        timeLabel.text = String(format: "%02d.%02d", countdownMinutes, countdownSeconds)
    }
    
   
    
    @IBAction func playButtonTapped(_ sender: Any) {
        let button = sender as! UIButton
        
        if button.imageView?.image == UIImage(systemName: "pause") {
            button.setImage(UIImage(systemName: "play"), for: .normal)
            pauseButtonTapped()
            return
        } else {
            button.setImage(UIImage(systemName: "pause"), for: .normal)
        }

        if animationRunning {
            resumeAnimation() // Eğer animasyon zaten başlatılmışsa, devam ettir
        } else {
            countdownTimer?.invalidate() // Önceki timer'ı iptal et
            updateCountdownLabel()
            
            countdownTimer = Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)

            circularCountdownTimeInterval = TimeInterval(countdownMinutes * 60 + countdownSeconds)
            startCircularCountdown(duration: circularCountdownTimeInterval!)
        }
    }
    
    func pauseButtonTapped(){
        countdownTimer?.invalidate()
        pauseAnimation()
    }
    
    
}

