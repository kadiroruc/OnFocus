//
//  StatisticsViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 22.04.2025.
//

import UIKit
import DGCharts

class StatisticsViewController: UIViewController {
    
    
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
        stack.backgroundColor = UIColor(hex: "#FFB570")
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()


    private let chartView: LineChartView = {
        let chartView =  LineChartView()
        chartView.backgroundColor = .clear
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelTextColor = UIColor(hex: "#70C1B3", alpha: 1)
        chartView.leftAxis.labelTextColor = UIColor(hex: "#70C1B3", alpha: 1)
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.translatesAutoresizingMaskIntoConstraints = false
        

        let marker = BalloonMarker()
        marker.chartView = chartView
        chartView.marker = marker
        
        return chartView
    }()
    
    private let statisticsContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = UIColor(hex: "#FBE2C8", alpha: 1)
        stackView.layer.cornerRadius = 20
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let averageView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let averageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor(hex: "#333333", alpha: 1)
        return label
    }()
    
    private let averageTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = UIColor(hex: "#70C1B3", alpha: 1)
        label.textColor = .white
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private let progressPercentageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = UIColor(hex: "#FF8A5C", alpha: 1)
        label.textColor = .white
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        averageLabel.text = "Ortalama: "
        averageTimeLabel.text = "8 saat"
        progressLabel.text = "İlerleme: "
        progressPercentageLabel.text = "-%28"
        
        setData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.setGradientBackground(colors: [UIColor(hex: "#FEF6F0"), .white])
    }
    
    func setupView(){
        toggleStack.addArrangedSubview(oneWeekButton)
        toggleStack.addArrangedSubview(oneMonthButton)
        toggleStack.addArrangedSubview(oneYearButton)
        toggleStack.addArrangedSubview(fiveYearsButton)

        view.addSubview(toggleStack)
        view.addSubview(chartView)
        view.addSubview(statisticsContainerView)
        statisticsContainerView.addArrangedSubview(averageView)
        averageView.addSubview(averageLabel)
        averageView.addSubview(averageTimeLabel)
        statisticsContainerView.addArrangedSubview(progressView)
        progressView.addSubview(progressLabel)
        progressView.addSubview(progressPercentageLabel)
        
        
        NSLayoutConstraint.activate([
            
            toggleStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 16),
            toggleStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            toggleStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            toggleStack.heightAnchor.constraint(equalToConstant: 50),
            
            chartView.topAnchor.constraint(equalTo: toggleStack.bottomAnchor, constant: 40),
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalTo: chartView.widthAnchor),
            
            statisticsContainerView.topAnchor.constraint(equalTo: chartView.bottomAnchor,constant: 40),
            statisticsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statisticsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statisticsContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            
            averageLabel.centerYAnchor.constraint(equalTo: averageView.centerYAnchor),
            averageLabel.leadingAnchor.constraint(equalTo: averageView.leadingAnchor, constant: 30),
            averageLabel.widthAnchor.constraint(equalToConstant: 100),
            
            
            averageTimeLabel.centerYAnchor.constraint(equalTo: averageView.centerYAnchor),
            averageTimeLabel.trailingAnchor.constraint(equalTo: averageView.trailingAnchor, constant: -30),
            averageTimeLabel.widthAnchor.constraint(equalToConstant: 100),
            averageTimeLabel.heightAnchor.constraint(equalToConstant: 50),
            
            progressLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            progressLabel.leadingAnchor.constraint(equalTo: progressView.leadingAnchor, constant: 30),
            progressLabel.widthAnchor.constraint(equalToConstant: 100),
            
            
            progressPercentageLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            progressPercentageLabel.trailingAnchor.constraint(equalTo: progressView.trailingAnchor, constant: -30),
            progressPercentageLabel.widthAnchor.constraint(equalToConstant: 100),
            progressPercentageLabel.heightAnchor.constraint(equalToConstant: 50),
            
            
        ])
        
    }


    func setData() {
        let values: [Double] = [8, 10, 6, 2, 7, 0, 8]
        let entries = values.enumerated().map { index, value in
            ChartDataEntry(x: Double(index), y: value)
        }

        let set = LineChartDataSet(entries: entries, label: "Work Time")
        set.mode = .cubicBezier
        set.drawCirclesEnabled = false
        set.lineWidth = 2
        set.setColor(UIColor(hex: "#70C1B3", alpha: 1))
        set.fillColor = UIColor(hex: "#70C1B3", alpha: 1)
        set.drawFilledEnabled = true
        set.fillAlpha = 0.2
        set.drawValuesEnabled = false
        set.highlightEnabled = true
        set.drawHorizontalHighlightIndicatorEnabled = false
        set.drawVerticalHighlightIndicatorEnabled = false

        let data = LineChartData(dataSet: set)
        chartView.data = data
    }
    
    @objc func oneWeekButtonTapped(){
        oneWeekButton.backgroundColor = UIColor(hex: "#FEF6F0")
        oneWeekButton.setTitleColor(UIColor(hex: "#333333"), for: .normal)
        oneMonthButton.backgroundColor = UIColor(hex: "FFB570")
        oneMonthButton.setTitleColor(.white, for: .normal)
        oneYearButton.backgroundColor = UIColor(hex: "FFB570")
        oneYearButton.setTitleColor(.white, for: .normal)
        fiveYearsButton.backgroundColor = UIColor(hex: "FFB570")
        fiveYearsButton.setTitleColor(.white, for: .normal)
    }
    
    @objc func oneMonthButtonTapped(){
        oneMonthButton.backgroundColor = UIColor(hex: "#FEF6F0")
        oneMonthButton.setTitleColor(UIColor(hex: "#333333"), for: .normal)
        oneWeekButton.backgroundColor = UIColor(hex: "FFB570")
        oneWeekButton.setTitleColor(.white, for: .normal)
        oneYearButton.backgroundColor = UIColor(hex: "FFB570")
        oneYearButton.setTitleColor(.white, for: .normal)
        fiveYearsButton.backgroundColor = UIColor(hex: "FFB570")
        fiveYearsButton.setTitleColor(.white, for: .normal)
        
    }
    
    @objc func oneYearButtonTapped(){
        oneYearButton.backgroundColor = UIColor(hex: "#FEF6F0")
        oneYearButton.setTitleColor(UIColor(hex: "#333333"), for: .normal)
        oneWeekButton.backgroundColor = UIColor(hex: "FFB570")
        oneWeekButton.setTitleColor(.white, for: .normal)
        oneMonthButton.backgroundColor = UIColor(hex: "FFB570")
        oneMonthButton.setTitleColor(.white, for: .normal)
        fiveYearsButton.backgroundColor = UIColor(hex: "FFB570")
        fiveYearsButton.setTitleColor(.white, for: .normal)
        
    }
    
    @objc func fiveYearsButtonTapped(){
        fiveYearsButton.backgroundColor = UIColor(hex: "#FEF6F0")
        fiveYearsButton.setTitleColor(UIColor(hex: "#333333"), for: .normal)
        oneWeekButton.backgroundColor = UIColor(hex: "FFB570")
        oneWeekButton.setTitleColor(.white, for: .normal)
        oneMonthButton.backgroundColor = UIColor(hex: "FFB570")
        oneMonthButton.setTitleColor(.white, for: .normal)
        oneYearButton.backgroundColor = UIColor(hex: "FFB570")
        oneYearButton.setTitleColor(.white, for: .normal)
        
    }
}

#Preview("StatisticsViewController"){
    StatisticsViewController()
}

