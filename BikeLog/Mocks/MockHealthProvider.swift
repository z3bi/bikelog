//
//  MockHealthProvider.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/13/22.
//

import Foundation
import Combine

class MockHealthProvider: HealthProvider {
    
    init(unit: UnitLength = .miles) {
        self.unit = unit
    }
    
    let unit: UnitLength
    
    func generateWorkout(activity: WorkoutActivity, dayOffset: Int = 1) -> Workout {
        let distance: Measurement<UnitLength>
        let duration: TimeInterval
        switch activity {
        case .cycling:
            distance = Measurement(value: Double.random(in: 15...30), unit: unit)
            let mph = Double.random(in: 10...20)
            duration = (distance.value / mph) * 60 * 60
        case .running:
            distance = Measurement(value: Double.random(in: 2...5), unit: unit)
            let mph = Double.random(in: 5...7)
            duration = (distance.value / mph) * 60 * 60
        case .walking:
            distance = Measurement(value: Double.random(in: 0.5...1.5), unit: unit)
            let mph = Double.random(in: 3...4)
            duration = (distance.value / mph) * 60 * 60
        }
        let start = Date().addingTimeInterval((-1 * (Double(dayOffset) * 60 * 60 * 24)) - Double.random(in: 60...9999))
        
        let end = start.addingTimeInterval(duration)
        
        return Workout(id: UUID(),
                       startDate: start,
                       endDate: end,
                       activity: activity,
                       duration: duration,
                       distance: distance)
    }
    
    func generateWorkouts(activity: WorkoutActivity) -> [Workout] {
        (0...100).map { generateWorkout(activity: activity, dayOffset: $0) }
    }
    
    func fetchWorkouts(activity: WorkoutActivity) async -> (workouts: [Workout], unit: UnitLength) {
        do {
            try await Task.sleep(nanoseconds: 2000000000)
        } catch {
            print("\(error)")
        }
        let workouts = generateWorkouts(activity: activity)
        return (workouts: workouts, unit: unit)
    }
}

extension WorkoutManager {
    static func mock(activity: WorkoutActivity = .cycling, unit: UnitLength = .miles) -> WorkoutManager {
        WorkoutManager(healthProvider: MockHealthProvider(unit: unit))
    }
}
