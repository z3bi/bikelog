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
}

extension Workout {
    init(id: UUID, startDate: Date, endDate: Date, type: WorkoutType, duration: TimeInterval, distance: Measurement<UnitLength>, unit: UnitLength) {
        let speed = (distance / Measurement(value: duration, unit: .seconds)).converted(to: type.speedUnit(for: unit))

        self.init(id: id,
                  startDate: startDate,
                  endDate: endDate,
                  type: type,
                  duration: duration,
                  distance: distance,
                  unit: unit,
                  speed: speed)
    }
    
    init?(hkWorkout: HKWorkout, hkUnit: HKUnit) {
        guard let type = WorkoutType(activityType: hkWorkout.workoutActivityType) else {
            return nil
        }
        
        let distance = Measurement(value: hkWorkout.totalDistance?.doubleValue(for: hkUnit) ?? 0,
                                    unit: hkUnit.lengthUnit())

        self.init(id: hkWorkout.uuid,
                  startDate: hkWorkout.startDate,
                  endDate: hkWorkout.endDate,
                  type: type,
                  duration: hkWorkout.duration,
                  distance: distance,
                  unit: hkUnit.lengthUnit())
    }
}
