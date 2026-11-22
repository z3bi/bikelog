//
//  StatisticalPeriod.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import Foundation
import OSLog

enum StatisticalPeriod: String, CaseIterable {
    private static let logger = Logger(subsystem: "BikeLog", category: "Workout totals")

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
    
    func dateInterval(from date: Date = .now, calendar: Calendar = .current) -> DateInterval {
        var calendar = calendar
        let component: Calendar.Component
        switch self {
        case .all:
            return DateInterval(start: .distantPast, end: .distantFuture)
        case .year:
            component = .year
        case .month:
            component = .month
        case .week:
            calendar.firstWeekday = 2
            component = .weekOfYear
        }

        guard let interval = calendar.dateInterval(of: component, for: date) else {
            Self.logger.error("Could not determine the date interval for \(self.rawValue).")
            return DateInterval(start: date, end: date)
        }
        return interval
    }
}
