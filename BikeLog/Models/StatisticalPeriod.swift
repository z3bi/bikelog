//
//  StatisticalPeriod.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import Foundation

enum StatisticalPeriod: String, CaseIterable {
    case all
    case year
    case month
    case week
    
    var name: String {
        switch self {
        case .all:
            return String(localized: "All")
        case .year:
            return String(localized: "Year")
        case .month:
            return String(localized: "Month")
        case .week:
            return String(localized: "Week")
        }
    }
    
    func dateInterval(from date: Date = Date()) -> DateInterval {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .weekday], from: date)
        guard let year = comps.year, let month = comps.month, let weekday = comps.weekday else {
            return DateInterval(start: date, end: date)
        }
        
        let startDate: Date
        let endDate: Date
        
        switch self {
        case .all:
            startDate = .distantPast
            endDate = .distantFuture
        case .year:
            startDate = cal.date(from: DateComponents(year: year, month: 1, day: 1)) ?? date
            endDate = cal.date(from: DateComponents(year: year + 1, month: 1, day: 1)) ?? date
        case .month:
            startDate = cal.date(from: DateComponents(year: year, month: month, day: 1)) ?? date
            endDate = cal.date(from: DateComponents(year: year, month: month + 1, day: 1)) ?? date
        case .week:
            if weekday == 2 {
                startDate = cal.startOfDay(for: date)
            } else {
                let monday = cal.nextDate(after: date, matching: DateComponents(weekday: 2), matchingPolicy: .nextTime, direction: .backward) ?? date
                startDate = cal.startOfDay(for: monday)
            }
            endDate = cal.date(byAdding: .day, value: 7, to: startDate) ?? date
        }
        
        return DateInterval(start: startDate, end: endDate)
    }
}
