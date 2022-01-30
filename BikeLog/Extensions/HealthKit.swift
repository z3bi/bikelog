//
//  HealthKit.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import Foundation
import HealthKit

extension HKWorkout {
    static func distanceType(for activityType: HKWorkoutActivityType) -> HKQuantityType {
        switch activityType {
        case .cycling:
            return HKQuantityType.quantityType(forIdentifier: .distanceCycling)!
        default:
            return HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        }
    }
}

extension UnitLength {
    func hkUnit() -> HKUnit {
        switch self {
        case .miles:
            return .mile()
        case .kilometers:
            return .meterUnit(with: .kilo)
        default:
            return .meter()
        }
    }
}

extension HKUnit {
    func lengthUnit() -> UnitLength {
        switch self.unitString {
        case "mi":
            return UnitLength.miles
        case "km":
            return UnitLength.kilometers
        default:
            return UnitLength.meters
        }
    }
}
