//
//  StatisticsViewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 19.05.2025.
//
import Foundation
import FirebaseFirestore
import UIKit

protocol StatisticsViewModelInterface {
    var view: StatisticsViewInterface? { get set }
    func loadStatistics(for type: FetchTimeRangeType)
    func generateXLabels(from statistics: [StatisticModel]) -> [String]
    func viewWillAppear()
    func viewWillDisappear()
    
}

final class StatisticsViewModel {
    weak var view: StatisticsViewInterface?
    private let timerService: TimerServiceProtocol
    
    private var statisticsCache: [FetchTimeRangeType: [StatisticModel]] = [:]
    private var averageCache: [FetchTimeRangeType: Double] = [:]
    private var previousAverageCache: [FetchTimeRangeType: Double] = [:]
    private var currentRangeType: FetchTimeRangeType?
    private var statisticsListener: StatisticsListenerToken?
    private var averageListener: ListenerRegistration?

    init(timerService: TimerServiceProtocol) {
        self.timerService = timerService
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(significantTimeChange), name: UIApplication.significantTimeChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func formatDate(from string: String, format: String, to outputFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let date = formatter.date(from: string) {
            formatter.dateFormat = outputFormat
            return formatter.string(from: date)
        }
        return string
    }
    
    private func updateAverageDisplay(currentAverage: Double, type: FetchTimeRangeType) {
        let totalMinutes = Int(currentAverage) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        var formatted = ""
        if hours > 0 { formatted += "\(hours)h" }
        if minutes > 0 || hours == 0 {
            if !formatted.isEmpty { formatted += " " }
            formatted += "\(minutes)m"
        }

        self.view?.updateAverageLabel(with: formatted)

        // Önceki ortalama cache kontrolü
        if let previous = previousAverageCache[type] {
            if previous != 0 {
                let percent = (currentAverage - previous) / previous * 100
                self.view?.updateProgressLabel(with: "\(String(format: "%.1f", percent))%")
            } else {
                self.view?.updateProgressLabel(with: "-")
            }
        } else {
            let previousDate = Calendar.current.date(byAdding: type.asCalendarComponent, value: type.offsetValue, to: Date())!
            timerService.fetchAverageDuration(for: type, from: previousDate) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let previous):
                    self.previousAverageCache[type] = previous
                    if previous != 0 {
                        let percent = (currentAverage - previous) / previous * 100
                        self.view?.updateProgressLabel(with: "\(String(format: "%.1f", percent))%")
                    } else {
                        self.view?.updateProgressLabel(with: "-")
                    }
                case .failure(let error):
                    print("Geçmiş ortalama alınamadı: \(error)")
                }
            }
        }
    }
    
    private func startObservers(for type: FetchTimeRangeType) {
        stopObservers()
        
        statisticsListener = timerService.observeStatistics(for: type, from: Date()) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let statistics):
                    if let cached = self.statisticsCache[type], cached == statistics {
                        return
                    }
                    self.statisticsCache[type] = statistics
                    self.view?.updateChart(with: statistics)
                case .failure(let error):
                    print("İstatistik gözlem hatası: \(error)")
                }
            }
        }
        
        averageListener = timerService.observeAverageDuration(for: type, from: Date()) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let avg):
                    if let cachedAvg = self.averageCache[type], cachedAvg == avg {
                        return
                    }
                    self.averageCache[type] = avg
                    self.updateAverageDisplay(currentAverage: avg, type: type)
                case .failure(let error):
                    print("Ortalama gözlem hatası: \(error)")
                }
            }
        }
    }
    
    private func stopObservers() {
        statisticsListener?.remove()
        statisticsListener = nil
        
        averageListener?.remove()
        averageListener = nil
    }
    
    @objc private func appDidBecomeActive() {
        refreshObserversIfNeeded()
    }
    
    @objc private func significantTimeChange() {
        refreshObserversIfNeeded()
    }
    
    private func refreshObserversIfNeeded() {
        guard let currentRangeType, statisticsListener != nil else { return }
        startObservers(for: currentRangeType)
    }
}
    
extension StatisticsViewModel: StatisticsViewModelInterface {
    func loadStatistics(for type: FetchTimeRangeType) {
        if currentRangeType == type, statisticsListener != nil {
            return
        }
        currentRangeType = type
        startObservers(for: type)
        // Cache kontrolü
        if let cachedStats = statisticsCache[type] {
            self.view?.updateChart(with: cachedStats)
        }
        // Ortalama kontrolü
        if let cachedAvg = averageCache[type] {
            self.updateAverageDisplay(currentAverage: cachedAvg, type: type)
        }
    }
    
    func viewWillAppear() {
        if let currentRangeType {
            startObservers(for: currentRangeType)
        }
    }
    
    func viewWillDisappear() {
        stopObservers()
    }
    
    
    func generateXLabels(from statistics: [StatisticModel]) -> [String] {
        return statistics.compactMap { model in
            guard let name = model.documentName else { return "" }

            if name.starts(with: "daily_") {
                let dateString = String(name.dropFirst(6))
                return formatDate(from: dateString, format: "yyyyMMdd", to: "MM/dd")
                
            } else if name.starts(with: "weekly_") {
                return String(name.dropFirst(12))
                
            } else if name.starts(with: "monthly_") {
                let monthString = String(name.dropFirst(13))
                if let monthIndex = Int(monthString), (1...12).contains(monthIndex) {
                    let formatter = DateFormatter()
                    formatter.locale = Locale.current
                    let symbols = formatter.shortMonthSymbols ?? []
                    if symbols.indices.contains(monthIndex - 1) {
                        return symbols[monthIndex - 1]
                    }
                }
                return monthString

            } else if name.starts(with: "yearly_") {
                return String(name.dropFirst(7)) // Örn: "2025"
                
            } else {
                return name
            }
        }
    }
}
    
