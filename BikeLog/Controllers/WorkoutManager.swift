//
//  WorkoutManager.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import Foundation
import Combine
import UIKit
import SwiftUI

class WorkoutManager: ObservableObject {
    @Published private(set) var workouts: [Workout] = []
    private(set) var unit: UnitLength
    
    var sort: WorkoutSort = .date {
        didSet {
            setWorkouts(workouts)
        }
    }
    
    @AppStorage(DefaultKey.workoutActivity.rawValue)
    var activity: WorkoutActivity = .cycling {
        willSet {
            if activity != newValue {
                workouts = []
            }
        }
        didSet {
            if activity != oldValue {
                Task {
                    await fetchWorkouts()
                }
            }
        }
    }
    
    let healthProvider: HealthProvider
    
    init(healthProvider: HealthProvider) {
        self.healthProvider = healthProvider
        self.unit = Locale.current.distanceUnit()
    }

    @MainActor
    func fetchWorkouts() async {
        let (workoutData, preferredUnit) = await healthProvider.fetchWorkouts(activity: activity)
        unit = preferredUnit
        setWorkouts(workoutData)
    }
    
    // MARK: Internal

    private func setWorkouts(_ newWorkouts: [Workout]) {
        workouts = sort.sortedWorkouts(newWorkouts)
    }
}
