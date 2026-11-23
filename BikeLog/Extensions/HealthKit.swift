//
//  HealthKit.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import Foundation
import HealthKit

extension HKWorkout {
    static var cyclingDistanceType: HKQuantityType {
        HKQuantityType.quantityType(forIdentifier: .distanceCycling)!
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
