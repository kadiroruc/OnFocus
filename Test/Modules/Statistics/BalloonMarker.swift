//
//  BalloonMarker.swift
//  Test
//
//  Created by Abdulkadir Oruç on 22.04.2025.
//

import UIKit
import DGCharts

class BalloonMarker: MarkerView {

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.8)
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        label.text = String(format: "%.2f", entry.y)
        label.sizeToFit()
        label.frame = CGRect(origin: .zero, size: CGSize(width: label.frame.width + 16, height: label.frame.height + 8))
        self.frame = label.frame
    }

    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        let x = max(
            min(point.x - self.bounds.width / 2, (self.chartView?.bounds.width ?? 0) - self.bounds.width),
            0
        )
        return CGPoint(x: x - point.x, y: -self.bounds.height)
    }

    override func draw(context: CGContext, point: CGPoint) {
        super.draw(context: context, point: point)
    }
}

