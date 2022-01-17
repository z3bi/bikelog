//
//  StatisticalPeriod.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import Foundation

enum StatisticalPeriod {
    case all
    case year
    case month
    case week
    
    var name: String {
        switch self {
        case .all:
            return NSLocalizedString("All", comment: "")
        case .year:
            return NSLocalizedString("Year", comment: "")
        case .month:
            return NSLocalizedString("Month", comment: "")
        case .week:
            return NSLocalizedString("Week", comment: "")
        }
    }
    
    func dateInterval(from date: Date = Date()) -> DateInterval {
        switch self {
        case .all:
            return DateInterval(start: .distantPast, end: .distantFuture)
        case .year:
            var startComponents = Calendar.gregorian.dateComponents([.year, .month, .day], from: date)
            startComponents.day = 1
            startComponents.month = 1
            var endComponents = Calendar.gregorian.dateComponents([.year, .month, .day], from: date)
            endComponents.year? += 1
            endComponents.day = 1
            endComponents.month = 1
            guard let start = Calendar.gregorian.date(from: startComponents), let end = Calendar.gregorian.date(from: endComponents) else {
                return DateInterval(start: date, end: date)
            }
            
            return DateInterval(start: Calendar.gregorian.startOfDay(for: start), end: Calendar.gregorian.startOfDay(for: end).addingTimeInterval(-1))
        case .month:
            var startComponents = Calendar.gregorian.dateComponents([.year, .month, .day], from: date)
            startComponents.day = 1
            var endComponents = Calendar.gregorian.dateComponents([.year, .month, .day], from: date)
            endComponents.month? += 1
            endComponents.day = 1
            guard let start = Calendar.gregorian.date(from: startComponents), let end = Calendar.gregorian.date(from: endComponents) else {
                return DateInterval(start: date, end: date)
            }
            
            return DateInterval(start: Calendar.gregorian.startOfDay(for: start), end: Calendar.gregorian.startOfDay(for: end).addingTimeInterval(-1))
        case .week:
            var offset = Calendar.gregorian.component(.weekday, from: date) - 2
            offset = offset < 0 ? 6 : offset
            var startComponents = Calendar.gregorian.dateComponents([.year, .month, .day], from: date)
            startComponents.day? -= offset
            var endComponents = Calendar.gregorian.dateComponents([.year, .month, .day], from: date)
            endComponents.day? += (7 - offset)
            guard let start = Calendar.gregorian.date(from: startComponents), let end = Calendar.gregorian.date(from: endComponents) else {
                return DateInterval(start: date, end: date)
            }
            
            return DateInterval(start: Calendar.gregorian.startOfDay(for: start), end: Calendar.gregorian.startOfDay(for: end).addingTimeInterval(-1))
        }
    }
    
    func filterWorkouts(_ workouts: [Workout], date: Date = Date()) -> [Workout] {
        let interval = dateInterval(from: date)
        return workouts.filter { interval.contains($0.startDate) }
    }
}
