//
//  FetchTimeRange.swift
//  Test
//
//  Created by Abdulkadir Oruç on 18.05.2025.
//

import Foundation

enum FetchTimeRangeType {
    case  week, month, year, fiveYears
}

extension FetchTimeRangeType {
    var asCalendarComponent: Calendar.Component {
        switch self {
        case .week:
            return .weekOfYear
        case .month:
            return .month
        case .year:
            return .year
        case .fiveYears:
            return .year
        }
    }

    var offsetValue: Int {
        switch self {
        case .week:
            return -1
        case .month:
            return -1
        case .year:
            return -1
        case .fiveYears:
            return -5
        }
    }
}
