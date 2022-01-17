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
            return NSLocalizedString("Date", comment: "")
        case .distance:
            return NSLocalizedString("Distance", comment: "")
        case .speed:
            return NSLocalizedString("Speed", comment: "")
        }
    }
    
    func sort(_ workouts: [Workout]) -> [Workout] {
        switch self {
        case .date:
            return workouts.sorted(comparingKeyPath: \.startDate, ascending: false)
        case .distance:
            return workouts.sorted(comparingKeyPath: \.distance, ascending: false)
        case .speed:
            return workouts.sorted(comparingKeyPath: \.speed, ascending: false)
        }
    }
}