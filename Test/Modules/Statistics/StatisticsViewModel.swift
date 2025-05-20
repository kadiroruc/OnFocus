//
//  StatisticsViewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 19.05.2025.
//
import Foundation

protocol StatisticsViewModelInterface {
    var view: StatisticsViewInterface? { get set }
    func loadStatistics(for type: FetchTimeRangeType)
    func generateXLabels(from statistics: [StatisticModel]) -> [String]
    
}

final class StatisticsViewModel {
    weak var view: StatisticsViewInterface?
    private let timerService: TimerServiceProtocol

    init(service: TimerServiceProtocol) {
        self.timerService = service
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
}
    
extension StatisticsViewModel: StatisticsViewModelInterface {
    func loadStatistics(for type: FetchTimeRangeType) {
        timerService.fetchStatistics(for: type, from: Date()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let statistics):
                self.view?.updateChart(with: statistics)
                
            case .failure(let error):
                print("İstatistikler alınamadı: \(error)")
            }
        }
        
        var currentAverage: Double = 0
        timerService.fetchAverageDuration(for: type, from: Date()) {[weak self] result in
            guard let self = self else { return }
            
            switch result{
            case.success(let average):
                currentAverage = average
                let totalMinutes = Int(average) / 60
                let hours = totalMinutes / 60
                let minutes = totalMinutes % 60
                
                var formatted = ""
                if hours > 0 {
                    formatted += "\(hours) saat"
                }
                if minutes > 0 || hours == 0 {
                    if !formatted.isEmpty { formatted += " " }
                    formatted += "\(minutes) dakika"
                }
                self.view?.updateAverageLabel(with: formatted)
            case .failure(let error):
                print("Ortalama değer alınamadı: \(error)")
            }
        }
        

        let previous = Calendar.current.date(byAdding: type.asCalendarComponent , value: -1, to: Date())!
        
        timerService.fetchAverageDuration(for: type, from: previous) { [weak self] result in
            guard let self = self else { return }
            
            switch result{
            case.success(let average):
                guard average != 0 else { return }
                let percentageChange = (Double(currentAverage - average) / Double(average)) * 100
                self.view?.updateProgressLabel(with: String(percentageChange))
            case .failure(let error):
                print("Ortalama değer alınamadı: \(error)")
            }
        }
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
                let name = String(name.dropFirst(13))
                switch name{
                case "01":
                    return "Jan"
                case "02":
                    return "Feb"
                case "03":
                    return "Mar"
                case "04":
                    return "Apr"
                case "05":
                    return "May"
                case "06":
                    return "Jun"
                case "07":
                    return "Jul"
                case "08":
                    return "Aug"
                case "09":
                    return "Sep"
                case "10":
                    return "Oct"
                case "11":
                    return "Nov"
                case "12":
                    return "Dec"
                default:
                    return name
                }

            } else if name.starts(with: "yearly_") {
                return String(name.dropFirst(7)) // Örn: "2025"
                
            } else {
                return name
            }
        }
    }
}
    
