//
//  WorkoutType.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/12/22.
//

import Foundation
import HealthKit

enum WorkoutActivity: String, Codable, CaseIterable {
    case cycling
    case running
    case walking
    
    var name: String {
        switch self {
        case .cycling:
            return String(localized: "Cycling")
        case .running:
            return String(localized: "Running")
        case .walking:
            return String(localized: "Walking")
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
    
    init?(hkActivityType: HKWorkoutActivityType) {
        switch hkActivityType {
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
    
    var hkActivityType: HKWorkoutActivityType {
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
