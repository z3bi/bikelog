//
//  WorkoutType.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/12/22.
//

import Foundation
import HealthKit

enum Activity: String, Codable, CaseIterable {
    case cycling
    
    var name: String {
        switch self {
        case .cycling:
            return String(localized: "Cycling")
        }
    }

    func workoutCount(_ count: Int) -> String {
        switch self {
        case .cycling:
            return String.localizedStringWithFormat(String(localized: "%d rides"), count)
        }
    }
    
    func speedUnit(for lengthUnit: UnitLength) -> UnitSpeed {
        switch self {
        case .cycling:
            return lengthUnit.speedUnit
        }
    }
    
    init?(hkActivityType: HKWorkoutActivityType) {
        switch hkActivityType {
        case .cycling:
            self = .cycling
        default:
            return nil
        }
    }
    
    var hkActivityType: HKWorkoutActivityType {
        switch self {
        case .cycling:
            return .cycling
        }
    }
}
