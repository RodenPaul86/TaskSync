//
//  Date+Extentsions.swift
//  TaskSync
//
//  Created by Paul  on 3/30/25.
//

import SwiftUI

/// Date extentsions needed for building UI
extension Date {
    /// Custom Date Format
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// Checking whether the date is today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// Checking if the date is same hour
    var isSameHour: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .hour) == .orderedSame
    }
    
    /// Checking if the date is past hours
    var isPast: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .hour) == .orderedAscending
    }
    
    /// Fetching week based on given date
    func fetchWeek(_ date: Date = .init()) -> [WeekDay] {
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: date)
        
        var week: [WeekDay] = []
        let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        guard let startOfWeek = weekForDate?.start else { return [] }
        
        (0..<7).forEach { index in
            if let weekDay = calendar.date(byAdding: .day, value: index, to: startOfWeek) {
                week.append(.init(date: weekDay))
            }
        }
        
        return week
    }
    
    /// Creating next week, based on the last current week's date
    func currentNextWeek() -> [WeekDay] {
        let calendar = Calendar.current
        let startOfLastDate = calendar.startOfDay(for: self)
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: startOfLastDate) else {
            return []
        }
        
        return fetchWeek(nextDate)
    }
    
    /// Creating previous week, based on the first current week's date
    func currentPreviousWeek() -> [WeekDay] {
        let calendar = Calendar.current
        let startOfFirstDate = calendar.startOfDay(for: self)
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: startOfFirstDate) else {
            return []
        }
        
        return fetchWeek(previousDate)
    }
    
    
    
    
    
    struct WeekDay: Identifiable {
        var id: UUID = .init()
        var date: Date
    }
    
    
    
}
