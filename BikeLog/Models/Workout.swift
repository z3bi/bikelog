//
//  Workout.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/12/22.
//

import Foundation
import HealthKit

struct Workout: Hashable, Equatable, Identifiable, Codable, Sendable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let distance: Measurement<UnitLength>

    var speed: Measurement<UnitSpeed> {
        distance / Measurement(value: duration, unit: .seconds)
    }

    static func countDescription(_ count: Int) -> String {
        String.localizedStringWithFormat(String(localized: "%d rides"), count)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Workout, rhs: Workout) -> Bool {
        lhs.id == rhs.id
    }
}

extension Workout {
    /// Distances are stored in meters and converted to the preferred unit only for display.
    init?(hkWorkout: HKWorkout) {
        guard hkWorkout.workoutActivityType == .cycling else { return nil }

        let distanceQuantity = hkWorkout.statistics(for: HealthTypes.cyclingDistance)?.sumQuantity() ?? hkWorkout.totalDistance
        guard let meters = distanceQuantity?.doubleValue(for: .meter()), meters > 10 else {
            return nil
        }
        
        self.init(id: hkWorkout.uuid,
                  startDate: hkWorkout.startDate,
                  endDate: hkWorkout.endDate,
                  duration: hkWorkout.duration,
                  distance: Measurement(value: meters, unit: .meters))
    }
}
