//
//  Workout.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/12/22.
//

import Foundation
import HealthKit

struct Workout: Hashable, Identifiable, Codable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let activity: WorkoutActivity
    let duration: TimeInterval
    let distance: Measurement<UnitLength>
    let speed: Measurement<UnitSpeed>
}

extension Workout {
    init(id: UUID, startDate: Date, endDate: Date, activity: WorkoutActivity, duration: TimeInterval, distance: Measurement<UnitLength>) {
        let speed = (distance / Measurement(value: duration, unit: .seconds)).converted(to: activity.speedUnit(for: distance.unit))

        self.init(id: id,
                  startDate: startDate,
                  endDate: endDate,
                  activity: activity,
                  duration: duration,
                  distance: distance,
                  speed: speed)
    }
    
    init?(hkWorkout: HKWorkout, hkUnit: HKUnit) {
        guard let activity = WorkoutActivity(hkActivityType: hkWorkout.workoutActivityType) else {
            return nil
        }
        
        let distance = Measurement(value: hkWorkout.totalDistance?.doubleValue(for: hkUnit) ?? 0,
                                    unit: hkUnit.lengthUnit())

        self.init(id: hkWorkout.uuid,
                  startDate: hkWorkout.startDate,
                  endDate: hkWorkout.endDate,
                  activity: activity,
                  duration: hkWorkout.duration,
                  distance: distance)
    }
}
