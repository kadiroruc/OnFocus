//
//  HomeViewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 3.03.2025.
//

import UIKit

protocol HomeViewModelInterface: AnyObject {
    var view: HomeViewInterface? { get set }
    var isPaused: Bool { get set }
    var animationRunning: Bool { get set}
    func toggleCountdown()
    func viewDidLoad()
    func startCountdown()
    func pauseCountdown()
    func resumeCountdown()
    func updateCountdown()
}

final class HomeViewModel {
    weak var view: HomeViewInterface?
    var animationRunning = false
    var isPaused: Bool = true
    
    private var countdownMinutes = 0
    private var countdownSeconds = 5
    private var splitSeconds = 59
    private var countdownTimer: Timer?
    
}

extension HomeViewModel: HomeViewModelInterface{
    func viewDidLoad() {
        view?.updateCountdownLabel(minutes: countdownMinutes, seconds: countdownSeconds)

    }
    
    func toggleCountdown() {
        if isPaused {
            if animationRunning{
                resumeCountdown()
            }else{
                startCountdown()
            }
        } else {
            pauseCountdown()
        }
        isPaused.toggle()
        view?.updatePlayButton(isPaused: isPaused) // View'a butonu değiştirmesi gerektiğini söylüyoruz
    }
    
    func startCountdown() {
        countdownTimer?.invalidate()
        //view?.updateCountdownLabel(minutes: <#T##Int#>, seconds: <#T##Int#>)
        countdownTimer = Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        view?.startCircularAnimation(duration: TimeInterval(countdownMinutes * 60 + countdownSeconds))
        
    }
    
    func pauseCountdown() {
        countdownTimer?.invalidate()
        view?.pauseCircularAnimation()
    }
    
    func resumeCountdown() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        view?.resumeCircularAnimation()
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
                splitSeconds = 59
            } else {
                splitSeconds -= 1
            }
            view?.updateCountdownLabel(minutes: countdownMinutes, seconds: countdownSeconds)
        } else {
            animationRunning = false
            countdownTimer?.invalidate()
        }
    }
    
}
