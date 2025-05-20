//
//  FetchTimeRangeTypeExtension.swift
//  Test
//
//  Created by Abdulkadir Oruç on 19.05.2025.
//
import Foundation

extension FetchTimeRangeType {
    var asCalendarComponent: Calendar.Component {
        switch self {
        case .week:
            return .day
        case .month:
            return .weekOfYear
        case .year:
            return .month
        case .fiveYears:
            return .year
        }
    }
}
