//
//  WorkoutSort.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/16/22.
//

import Foundation

enum WorkoutSort: CaseIterable {
    case date
    case distance
    case speed
    
    var name: String {
        switch self {
        case .date:
            return String(localized: "Date")
        case .distance:
            return String(localized: "Distance")
        case .speed:
            return String(localized: "Speed")
        }
    }
    
    func sortedWorkouts(_ workouts: [Workout]) -> [Workout] {
        switch self {
        case .date:
            return workouts.sorted(comparingKeyPath: \.startDate, ascending: false)
        case .distance:
            return workouts.sorted(comparingKeyPath: \.distance, ascending: false)
        case .speed:
            var ascending = false
            if workouts.first?.activity != .cycling {
                ascending = true
            }
            return workouts.sorted(comparingKeyPath: \.speed, ascending: ascending)
        }
    }
}
