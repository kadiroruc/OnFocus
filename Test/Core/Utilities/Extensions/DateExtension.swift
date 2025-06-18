//
//  DateExtension.swift
//  Test
//
//  Created by Abdulkadir Oruç on 14.06.2025.
//
import Foundation

extension Date {
    func stripTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components)!
    }
}
