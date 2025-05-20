//
//  StatisticsViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 22.04.2025.
//

import UIKit
import DGCharts

protocol StatisticsViewInterface: AnyObject {
    func updateChart(with statistics: [StatisticModel])
    func updateAverageLabel(with average: String)
    func updateProgressLabel(with progress: String)
}

class StatisticsViewController: UIViewController {
    private var viewModel: StatisticsViewModelInterface
    
    private let oneWeekButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("1W", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(toggleButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private let oneMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("1M", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(toggleButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private let oneYearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("1Y", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(toggleButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private let fiveYearsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("5Y", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(toggleButtonTapped(_:)), for: .touchUpInside)
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
        stack.backgroundColor = UIColor(hex: Constants.Colors.lightOrange)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()


    private let chartView: LineChartView = {
        let chartView =  LineChartView()
        chartView.backgroundColor = .clear
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelTextColor = UIColor(hex: Constants.Colors.darkGray)
        chartView.leftAxis.labelTextColor = UIColor(hex: Constants.Colors.darkGray)
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = true
        chartView.legend.verticalAlignment = .top
        chartView.legend.orientation = .horizontal
        chartView.legend.horizontalAlignment = .right
        chartView.legend.drawInside = false
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
        stackView.backgroundColor = UIColor(hex: Constants.Colors.palePeach, alpha: 1)
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
        label.textColor = UIColor(hex: Constants.Colors.darkGray, alpha: 1)
        return label
    }()
    
    private let averageTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = UIColor(hex: Constants.Colors.mintGreen, alpha: 1)
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
        label.backgroundColor = UIColor(hex: Constants.Colors.softOrange, alpha: 1)
        label.textColor = .white
        return label
    }()
    
    init(viewModel: StatisticsViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.view = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        averageLabel.text = "Ortalama: "
        progressLabel.text = "İlerleme: "
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.setGradientBackground(colors: [UIColor(hex: Constants.Colors.lightPeach), .white])
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
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
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
    
    func updateButtonStates(selectedButton: UIButton) {
        let buttons = [oneWeekButton, oneMonthButton, oneYearButton, fiveYearsButton]
        
        for button in buttons {
            if button == selectedButton {
                button.backgroundColor = UIColor(hex: Constants.Colors.lightPeach)
                button.setTitleColor(UIColor(hex: Constants.Colors.darkGray), for: .normal)
            } else {
                button.backgroundColor = UIColor(hex: Constants.Colors.lightOrange)
                button.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    @objc func toggleButtonTapped(_ sender: UIButton) {
        updateButtonStates(selectedButton: sender)
        switch sender.title(for: .normal) {
            case "1W":
                viewModel.loadStatistics(for: .week)
            case "1M":
                viewModel.loadStatistics(for: .month)
            case "1Y":
                viewModel.loadStatistics(for: .year)
            case "5Y":
                viewModel.loadStatistics(for: .fiveYears)
            default:
                break
        }
    }
    
}

extension StatisticsViewController: StatisticsViewInterface {
    func updateChart(with statistics: [StatisticModel]) {
        
        let values = statistics.map { Double($0.totalDuration)/(60*60) }
        let entries = values.enumerated().map { ChartDataEntry(x: Double($0.offset ), y: $0.element) }

        let set = LineChartDataSet(entries: entries, label: "Work Time (Hour)")
        set.mode = .linear
        set.drawCirclesEnabled = false
        set.setColor(UIColor(hex: Constants.Colors.mintGreen))
        set.fillColor = UIColor(hex: Constants.Colors.mintGreen)
        set.drawFilledEnabled = true
        set.fillAlpha = 0.2
        set.drawCirclesEnabled = false
        set.drawValuesEnabled = false
        set.highlightEnabled = true
        set.drawHorizontalHighlightIndicatorEnabled = false
        set.drawVerticalHighlightIndicatorEnabled = false
        chartView.xAxis.granularity = 1
        chartView.xAxis.granularityEnabled = true
        chartView.xAxis.labelCount = statistics.count
        
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.axisMaximum = Double(statistics.count <= 8 ? 8 : statistics.count)
        chartView.leftAxis.granularity = 1
        chartView.leftAxis.granularityEnabled = true
        chartView.leftAxis.labelCount = statistics.count <= 8 ? 8 : statistics.count
        chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(block: { value, _ in
            return "\(Int(value))"
        })
        
        let xLabels = viewModel.generateXLabels(from: statistics)
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xLabels)
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelRotationAngle = -45

        chartView.data = LineChartData(dataSet: set)
    }
    
    func updateAverageLabel(with average: String) {
        averageTimeLabel.text = average
    }

    func updateProgressLabel(with progress: String) {
        progressPercentageLabel.text = progress.hasPrefix("-") ? progress : "+\(progress)"
    }
    
}

//#Preview("StatisticsViewController"){
//    StatisticsViewController()
//}

