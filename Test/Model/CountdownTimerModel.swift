//
//  CountdownTimerModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 3.03.2025.
//

import Foundation

struct CountdownTimerModel {
    var minutes: Int
    var seconds: Int
    var splitSeconds: Int
    
    var totalTime: TimeInterval {
        return TimeInterval(minutes * 60 + seconds)
    }
}
