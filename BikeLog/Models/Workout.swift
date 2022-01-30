//
//  Workout.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/12/22.
//

import Foundation
import HealthKit

struct Workout: Hashable, Equatable, Identifiable, Codable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let activity: Activity
    let duration: TimeInterval
    private(set) var distance: Measurement<UnitLength>
    
    var speed: Measurement<UnitSpeed> {
        (distance / Measurement(value: duration, unit: .seconds)).converted(to: activity.speedUnit(for: distance.unit))
    }
    
    mutating func updateUnit(_ unit: UnitLength) {
        guard distance.unit != unit else { return }
        distance = distance.converted(to: unit)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Workout, rhs: Workout) -> Bool {
        lhs.id == rhs.id
    }
    
    static func updateWorkouts(_ workouts: [Workout], unit: UnitLength) -> [Workout] {
        workouts.map { workout in
            var mutableWorkout = workout
            mutableWorkout.updateUnit(unit)
            return mutableWorkout
        }
    }
}

extension Workout {
    init?(hkWorkout: HKWorkout, hkUnit: HKUnit) {
        guard let activity = Activity(hkActivityType: hkWorkout.workoutActivityType),
              let distance = hkWorkout.totalDistance?.doubleValue(for: hkUnit),
              distance > 0.01 else {
            return nil
        }
        
        self.init(id: hkWorkout.uuid,
                  startDate: hkWorkout.startDate,
                  endDate: hkWorkout.endDate,
                  activity: activity,
                  duration: hkWorkout.duration,
                  distance: Measurement(value: distance, unit: hkUnit.lengthUnit()))
    }
}
