//
//  StreakCalendarCell.swift
//  Test
//
//  Created by Abdulkadir Oruç on 12.05.2025.
//
import UIKit
import FSCalendar

class StreakCalendarCell: FSCalendarCell {
    
    var isStreak = false
    var isLeftConnected = false
    var isRightConnected = false
    
    private let streakLayer = CAShapeLayer()
    private let circleLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.insertSublayer(streakLayer, at: 0)
        contentView.layer.insertSublayer(circleLayer, above: streakLayer)
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        streakLayer.frame = bounds
        circleLayer.frame = bounds
        
        // 💡 Çubuk şekli
        let barPath = UIBezierPath()
        if isStreak {
            let barHeight: CGFloat = bounds.height * 0.81
            let y = bounds.midY - barHeight / 2 - 4

            if isLeftConnected {
                barPath.append(UIBezierPath(rect: CGRect(
                    x: 0,
                    y: y,
                    width: bounds.midX,
                    height: barHeight
                )))
            }
            if isRightConnected {
                barPath.append(UIBezierPath(rect: CGRect(
                    x: bounds.midX,
                    y: y,
                    width: bounds.maxX - bounds.midX,
                    height: barHeight
                )))
            }
        }
        streakLayer.path = barPath.cgPath
        streakLayer.fillColor = UIColor(hex: "FF8A5C", alpha: 0.3).cgColor
        streakLayer.strokeColor = nil
        
        // 💡 Daire şekli (sadece baş/son günlerde göster)
        let circleRadius = min(bounds.width, bounds.height) * 0.4
        let circleRect = CGRect(
            x: bounds.midX - circleRadius,
            y: bounds.midY - circleRadius - 4,
            width: circleRadius * 2,
            height: circleRadius * 2
        )
        let circlePath = UIBezierPath(ovalIn: circleRect)
        circleLayer.path = circlePath.cgPath
        
        if isStreak && (!isLeftConnected || !isRightConnected) {
            circleLayer.fillColor = UIColor(hex: "FF8A5C").cgColor
        } else {
            circleLayer.fillColor = UIColor.clear.cgColor
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isStreak = false
        isLeftConnected = false
        isRightConnected = false
    }
}

//#Preview("ProfileViewController"){
//    ProfileViewController()
//}
