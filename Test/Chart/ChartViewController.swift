//
//  ChartViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 11.03.2025.
//

import UIKit
import SwiftUI
import DGCharts


class ChartViewController: UIViewController {
    
    let lineChartView = LineChartView()
    var data: [(date: String, hours: Double)] = []
    
    // Button for selecting weekly or monthly data
    let weeklyButton = UIButton()
    let monthlyButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the buttons
        //setupButtons()
        
        // Setup the chart
        setupChart()
        
        // Initially load weekly data
        loadWeeklyData()
    }
    
    func setupChart() {
        lineChartView.frame = CGRect(x: 20, y: 150, width: self.view.frame.size.width - 40, height: 300)
        lineChartView.center.x = view.center.x
        view.addSubview(lineChartView)
        
        lineChartView.delegate = self
        
        lineChartView.rightAxis.enabled = false  // Disable the right axis
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.valueFormatter = DateFormatterXAxis() // Set custom date formatter
        lineChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)

        lineChartView.xAxis.drawGridLinesEnabled = false

        lineChartView.leftAxis.drawGridLinesEnabled = false
        //lineChartView.leftAxis.axisMinimum = 0.0
        
    }
    
    func setupButtons() {
        // Weekly Button
        weeklyButton.frame = CGRect(x: 20, y: 100, width: 100, height: 40)
        weeklyButton.setTitle("Weekly", for: .normal)
        weeklyButton.setTitleColor(.blue, for: .normal)
        weeklyButton.addTarget(self, action: #selector(loadWeeklyData), for: .touchUpInside)
        view.addSubview(weeklyButton)
        
        // Monthly Button
        monthlyButton.frame = CGRect(x: 130, y: 100, width: 100, height: 40)
        monthlyButton.setTitle("Monthly", for: .normal)
        monthlyButton.setTitleColor(.blue, for: .normal)
        monthlyButton.addTarget(self, action: #selector(loadMonthlyData), for: .touchUpInside)
        view.addSubview(monthlyButton)
    }
    
    @objc func loadWeeklyData() {
        // Sample Weekly Data (7 days in a week)
        data = [
            ("2023-03-01", 5.9),
            ("2023-03-02", 6.2),
            ("2023-03-03", 4.2),
            ("2023-03-04", 7.2),
            ("2023-03-05", 3.2),
            ("2023-03-06", 6.2),
            ("2023-03-07", 5.2)
        ]
        
        setData()
    }
    
    @objc func loadMonthlyData() {
        // Sample Monthly Data (30 days in a month)
        data = [
            ("2023-03-01", 5),
            ("2023-03-02", 4),
            ("2023-03-03", 6),
            ("2023-03-04", 7),
            ("2023-03-05", 8),
            ("2023-03-06", 6),
            ("2023-03-07", 4),
            ("2023-03-08", 5),
            ("2023-03-09", 3),
            ("2023-03-10", 4),
            ("2023-03-11", 6),
            ("2023-03-12", 7),
            // Add more days...
        ]
        
        setData()
    }
    
    func setData() {
        var entries: [ChartDataEntry] = []
        
        // Convert the date strings into ChartDataEntry objects
        for (index, item) in data.enumerated() {
            let date = item.date
            let hours = item.hours
            
            // Parse date string into Date object
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let dateObj = dateFormatter.date(from: date) {
                let chartEntry = ChartDataEntry(x: dateObj.timeIntervalSince1970, y: hours)
                entries.append(chartEntry)
            }
        }
        
        let dataSet = LineChartDataSet(entries: entries, label: "Working Hours")
        dataSet.colors = [.systemCyan]
        dataSet.circleColors = [.black]
        dataSet.circleRadius = 4
        dataSet.lineWidth = 4
        dataSet.drawValuesEnabled = false
        
        let data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
    }
}

class DateFormatterXAxis: IndexAxisValueFormatter {
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        return dateFormatter.string(from: date)
    }
}

extension ChartViewController: ChartViewDelegate{
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        // Show the selected value in the label
        
        
    }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: ViewController

    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }

    func makeUIViewController(context: Context) -> ViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}
#endif

struct MyViewControllerPreview: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            let vc = ChartViewController()
            return vc
        }
    }
}
