//
//  StatsViewModel.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/17/22.
//

import Foundation

struct StatsViewModel {
    let dateInterval: DateInterval
    let period: StatisticalPeriod
    let activity: Activity
    let unit: UnitLength
    let workouts: [Workout]
    private let calendar: Calendar
    
    init(date: Date, period: StatisticalPeriod, activity: Activity, unit: UnitLength, workouts: [Workout], calendar: Calendar = .current) {
        let interval = period.dateInterval(from: date, calendar: calendar)
        self.dateInterval = interval
        self.period = period
        self.activity = activity
        self.unit = unit
        self.workouts = WorkoutPeriodTotal.workouts(workouts, in: interval)
        self.calendar = calendar
    }

    var title: String {
        let dateFormat = Date.FormatStyle(calendar: calendar, timeZone: calendar.timeZone)
        switch period {
        case .all, .week:
            return period.name
        case .year:
            return dateInterval.start.formatted(dateFormat.year())
        case .month:
            return dateInterval.start.formatted(dateFormat.month(.abbreviated))
        }
    }

    func totalDistance() -> String {
        let distance = WorkoutPeriodTotal.distance(of: workouts, in: unit)
        let fractions = distance.value == 0 ? 0 : 1
        return distance.formatted(LengthFormat.lengthFormat(fractions: fractions))
    }
    
    func workoutCount() -> String {
        activity.workoutCount(workouts.count)
    }
}

