//
//  TimerService+Helpers.swift
//  Test
//
//  Created by Abdulkadir Oruç on 18.05.2025.
//
import Foundation

extension TimerService {
    func getStatDocIDs(for range: TimeRange) -> [String] {
        switch range {
        case .daily(let date):
            return ["daily_" + DateFormatter.yyyyMMdd.string(from: date)]
        case .weekly(let date):
            let days = datesInWeek(containing: date)
            return days.map { "daily_" + DateFormatter.yyyyMMdd.string(from: $0) }
        case .monthly(let date):
            let weeks = weeksInMonth(containing: date)
            return weeks.map { "weekly_" + $0 }
        case .yearly(let date):
            let months = monthsInYear(containing: date)
            return months.map { "monthly_" + $0 }
        case .fiveYears(let date):
            let years = yearsInFiveYears(containing: date)
            return years.map { "yearly_" + $0 }
        }
    }

    func weekKey(for date: Date) -> String {
        let week = calendar.component(.weekOfYear, from: date)
        let year = calendar.component(.year, from: date)
        return "\(year)-W\(week)"
    }

    func monthKey(for date: Date) -> String {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return "\(year)-" + String(format: "%02d", month)
    }

    func yearKey(for date: Date) -> String {
        "\(calendar.component(.year, from: date))"
    }
    
    func fiveYearsKey(for date: Date) -> String {
        let year = calendar.component(.year, from: date)
        return "\(year)-\(year - 5)"
    }

    func datesInWeek(containing date: Date) -> [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: weekInterval.start)
        }
    }

    func weeksInMonth(containing date: Date) -> [String] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] }
        var weekStarts: [String] = []
        var current = monthInterval.start
        while current < monthInterval.end {
            weekStarts.append(weekKey(for: current))
            current = calendar.date(byAdding: .weekOfYear, value: 1, to: current)!
        }
        return weekStarts
    }

    func monthsInYear(containing date: Date) -> [String] {
        let year = calendar.component(.year, from: date)
        return (1...12).map {
            "\(year)-" + String(format: "%02d", $0)
        }
    }

    func yearsInFiveYears(containing date: Date) -> [String] {
        let currentYear = calendar.component(.year, from: date)
        return (0..<5).map { "\(currentYear - $0)" }.reversed()
    }
    
    func daysInMonth(for date: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)
        return range?.count ?? 30 // varsayılan 30 gün
    }
    
    func weekKeyToDate(_ key: String) -> Date? {
        let components = key.split(separator: "_")
        guard components.count == 2,
              let year = Int(components[0]),
              let weekOfYear = Int(components[1]) else { return nil }

        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        calendar.minimumDaysInFirstWeek = 4

        var dateComponents = DateComponents()
        dateComponents.calendar = calendar
        dateComponents.weekOfYear = weekOfYear
        dateComponents.yearForWeekOfYear = year

        return calendar.date(from: dateComponents)
    }

    func monthKeyToDate(_ key: String) -> Date? {
        let components = key.split(separator: "_")
        guard components.count == 2,
              let year = Int(components[0]),
              let month = Int(components[1]) else { return nil }

        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 1

        return Calendar.current.date(from: dateComponents)
    }

}
