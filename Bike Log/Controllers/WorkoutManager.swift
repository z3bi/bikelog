//
//  WorkoutManager.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import Foundation
import Combine
import UIKit

@MainActor
class WorkoutManager: ObservableObject {
    @Published private(set) var workouts: [Workout] = []
    
    var sort: WorkoutSort = .date {
        didSet {
            setWorkouts(workouts)
        }
    }
    
    var type: WorkoutType = .cycling {
        willSet {
            if type != newValue {
                workouts = []
            }
        }
        didSet {
            if type != oldValue {
                Task {
                    await fetchWorkouts()
                }
            }
        }
    }
    
    let healthProvider: HealthProvider
    
    init(healthProvider: HealthProvider) {
        self.healthProvider = healthProvider
    }

    func fetchWorkouts() async {
        let (workoutData, preferredUnit) = await healthProvider.fetchWorkouts(type: type)
        print(">> did fetch workouts")
        unit = preferredUnit
        setWorkouts(workoutData)
    }
    
    func totalDistance() -> Measurement<UnitLength> {
        let initial = Measurement(value: 0, unit: unit)
        return workouts.reduce(initial) { $0 + $1.distance }
    }
    
    // MARK: Internal
    
    private var unit: UnitLength = .miles

    private func setWorkouts(_ newWorkouts: [Workout]) {
        workouts = sort.sort(newWorkouts)
    }
}
