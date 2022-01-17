//
//  WorkoutType.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/12/22.
//

import Foundation
import HealthKit

enum WorkoutType: CaseIterable {
    case cycling
    case running
    case walking
    
    var name: String {
        switch self {
        case .cycling:
            return NSLocalizedString("Cycling", comment: "")
        case .running:
            return NSLocalizedString("Running", comment: "")
        case .walking:
            return NSLocalizedString("Walking", comment: "")
        }
    }
    
    func speedUnit(for lengthUnit: UnitLength) -> UnitSpeed {
        switch self {
        case .cycling:
            return lengthUnit.speedUnit
        case .running, .walking:
            return lengthUnit.paceUnit
        }
    }
    
    init?(activityType: HKWorkoutActivityType) {
        switch activityType {
        case .cycling:
            self = .cycling
        case .running:
            self = .running
        case .walking:
            self = .walking
        default:
            return nil
        }
    }
    
    var hkWorkoutActivityType: HKWorkoutActivityType {
        switch self {
        case .cycling:
            return .cycling
        case .running:
            return .running
        case .walking:
            return .walking
        }
    }
}
