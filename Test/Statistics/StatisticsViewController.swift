//
//  StatisticsViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 22.04.2025.
//

import UIKit
import DGCharts

class StatisticsViewController: UIViewController {
    
    private let oneDayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("1D", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "#F0D8D3")
        button.layer.cornerRadius = 17
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(oneDayButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let oneWeekButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("1W", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(oneWeekButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let oneMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("1M", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(oneMonthButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let oneYearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("1Y", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(oneYearButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let fiveYearsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("5Y", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(fiveYearsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let toggleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        stack.layer.cornerRadius = 20
        stack.backgroundColor = UIColor(hex: "d2a197")
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()


    let chartView = LineChartView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupView()
        setupChart()
    }
    
    func setupView(){
        toggleStack.addArrangedSubview(oneDayButton)
        toggleStack.addArrangedSubview(oneWeekButton)
        toggleStack.addArrangedSubview(oneMonthButton)
        toggleStack.addArrangedSubview(oneYearButton)
        toggleStack.addArrangedSubview(fiveYearsButton)

        view.addSubview(toggleStack)
        
        NSLayoutConstraint.activate([
            toggleStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 10),
            toggleStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            toggleStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            toggleStack.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func setupChart() {
        chartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chartView)

        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chartView.topAnchor.constraint(equalTo: toggleStack.bottomAnchor, constant: 32),
            chartView.heightAnchor.constraint(equalToConstant: 300)
        ])

        chartView.backgroundColor = .clear
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelTextColor = .lightGray
        chartView.leftAxis.labelTextColor = .lightGray
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        
        let marker = BalloonMarker()
        marker.chartView = chartView
        chartView.marker = marker
        

        setData()
    }

    func setData() {
        let values: [Double] = [8, 10, 6, 2, 7, 0, 8]
        let entries = values.enumerated().map { index, value in
            ChartDataEntry(x: Double(index), y: value)
        }

        let set = LineChartDataSet(entries: entries, label: "Price")
        set.mode = .cubicBezier
        set.drawCirclesEnabled = false
        set.lineWidth = 2
        set.setColor(.systemGreen)
        set.fillColor = .systemGreen
        set.drawFilledEnabled = true
        set.fillAlpha = 0.2
        set.drawValuesEnabled = false

        let data = LineChartData(dataSet: set)
        chartView.data = data
    }
    
    @objc func oneDayButtonTapped(){
        oneDayButton.backgroundColor = UIColor(hex: "#F0D8D3")
        oneWeekButton.backgroundColor = UIColor(hex: "d2a197")
        oneMonthButton.backgroundColor = UIColor(hex: "d2a197")
        oneYearButton.backgroundColor = UIColor(hex: "d2a197")
        fiveYearsButton.backgroundColor = UIColor(hex: "d2a197")
    }
    
    @objc func oneWeekButtonTapped(){
        oneWeekButton.backgroundColor = UIColor(hex: "#F0D8D3")
        oneDayButton.backgroundColor = UIColor(hex: "d2a197")
        oneMonthButton.backgroundColor = UIColor(hex: "d2a197")
        oneYearButton.backgroundColor = UIColor(hex: "d2a197")
        fiveYearsButton.backgroundColor = UIColor(hex: "d2a197")
        
    }
    
    @objc func oneMonthButtonTapped(){
        oneMonthButton.backgroundColor = UIColor(hex: "#F0D8D3")
        oneWeekButton.backgroundColor = UIColor(hex: "d2a197")
        oneDayButton.backgroundColor = UIColor(hex: "d2a197")
        oneYearButton.backgroundColor = UIColor(hex: "d2a197")
        fiveYearsButton.backgroundColor = UIColor(hex: "d2a197")
        
    }
    
    @objc func oneYearButtonTapped(){
        oneYearButton.backgroundColor = UIColor(hex: "#F0D8D3")
        oneWeekButton.backgroundColor = UIColor(hex: "d2a197")
        oneMonthButton.backgroundColor = UIColor(hex: "d2a197")
        oneDayButton.backgroundColor = UIColor(hex: "d2a197")
        fiveYearsButton.backgroundColor = UIColor(hex: "d2a197")
        
    }
    
    @objc func fiveYearsButtonTapped(){
        fiveYearsButton.backgroundColor = UIColor(hex: "#F0D8D3")
        oneWeekButton.backgroundColor = UIColor(hex: "d2a197")
        oneMonthButton.backgroundColor = UIColor(hex: "d2a197")
        oneYearButton.backgroundColor = UIColor(hex: "d2a197")
        oneDayButton.backgroundColor = UIColor(hex: "d2a197")
        
    }
}

#Preview("StatisticsViewController"){
    StatisticsViewController()
}

