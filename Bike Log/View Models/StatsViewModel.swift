//
//  StatsViewModel.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/17/22.
//

import Foundation

struct StatsViewModel: Hashable {
    let dateInterval: DateInterval
    let period: StatisticalPeriod
    let type: WorkoutType
    let unit: UnitLength
    let workouts: [Workout]
    
    init(date: Date, period: StatisticalPeriod, type: WorkoutType, unit: UnitLength, workouts: [Workout]) {
        let interval = period.dateInterval(from: date)
        self.dateInterval = interval
        self.period = period
        self.type = type
        self.unit = unit
        self.workouts = workouts.filter { interval.contains($0.startDate) }
    }

    var title: String {
        switch period {
        case .all, .week:
            return period.name
        case .year:
            return dateInterval.start.formatted(.dateTime.year())
        case .month:
            return dateInterval.start.formatted(.dateTime.month(.abbreviated))
        }
    }

    func totalDistance() -> String {
        let initial = Measurement(value: 0, unit: unit)
        let distance = workouts.reduce(initial) { $0 + $1.distance }
        let fractions = distance.value == 0 ? 0 : 1
        return distance.formatted(LengthFormat.lengthFormat(fractions: fractions))
    }
    
    func workoutCount() -> String {
        switch type {
        case .cycling:
            return "\(workouts.count) rides"
        case .running:
            return "\(workouts.count) runs"
        case .walking:
            return "\(workouts.count) walks"
        }
    }
}

