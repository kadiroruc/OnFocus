//
//  Timestamp Extension.swift
//  Test
//
//  Created by Abdulkadir Oruç on 15.06.2025.
//

import FirebaseFirestore

extension Timestamp {
    func formattedRelativeString() -> String {
        let date = self.dateValue()
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US") // English locale

        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute], from: date, to: now)
        
        if let year = components.year, year > 0 {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date) // e.g., "Apr 10, 2024 at 3:24 PM"
        } else if let month = components.month, month > 0 {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date) // e.g., "Apr 10"
        } else if let week = components.weekOfYear, week > 0 {
            formatter.dateFormat = "EEEE" // full day name
            return formatter.string(from: date) // e.g., "Monday"
        } else if let day = components.day, day > 0 {
            if day == 1 {
                return "Yesterday"
            } else {
                return "\(day) days ago"
            }
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) hour\(hour == 1 ? "" : "s") ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) minute\(minute == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }
}
