//
//  HealthKit.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import Foundation
import HealthKit

enum HealthTypes {
    static let cyclingDistance = HKQuantityType(.distanceCycling)
    static let heartRate = HKQuantityType(.heartRate)
    static let activeEnergy = HKQuantityType(.activeEnergyBurned)

    /// Everything the app reads, requested together so the user sees a single prompt.
    static let read: Set<HKObjectType> = [
        .workoutType(),
        HKSeriesType.workoutRoute(),
        cyclingDistance,
        heartRate,
        activeEnergy,
    ]
}

extension HKUnit {
    var lengthUnit: UnitLength? {
        switch self {
        case .mile():
            return .miles
        case .meterUnit(with: .kilo):
            return .kilometers
        default:
            return nil
        }
    }
}
