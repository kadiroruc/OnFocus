//
//  TimeRangeEnum.swift
//  Test
//
//  Created by Abdulkadir Oruç on 18.05.2025.
//

import Foundation

enum TimeRange {
    case daily(Date)
    case weekly(Date)
    case monthly(Date)
    case yearly(Date)
    case fiveYears(Date)
}
