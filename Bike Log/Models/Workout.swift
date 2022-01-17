//
//  Workout.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/12/22.
//

import Foundation
import HealthKit

struct Workout: Hashable, Identifiable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let type: WorkoutType
    let duration: TimeInterval
    let distance: Measurement<UnitLength>
    let unit: UnitLength
    let speed: Measurement<UnitSpeed>
    
    static func fromHealthKit(workouts: [HKWorkout], unit: HKUnit) -> [Workout] {
        workouts.compactMap {
            guard let type = WorkoutType(activityType: $0.workoutActivityType) else {
                return nil
            }
            
            let distance = Measurement(value: $0.totalDistance?.doubleValue(for: unit) ?? 0,
                                       unit: unit.lengthUnit())

            return Workout(id: $0.uuid,
                    startDate: $0.startDate,
                    endDate: $0.endDate,
                    type: type,
                    duration: $0.duration,
                    distance: distance,
                    unit: unit.lengthUnit())
        }
    }
}

extension Workout {
    init(id: UUID, startDate: Date, endDate: Date, type: WorkoutType, duration: TimeInterval, distance: Measurement<UnitLength>, unit: UnitLength) {
        let speed = (distance / Measurement(value: duration, unit: .seconds)).converted(to: type.speedUnit(for: unit))
        self.init(id: id, startDate: startDate, endDate: endDate, type: type, duration: duration, distance: distance, unit: unit, speed: speed)
    }
}
