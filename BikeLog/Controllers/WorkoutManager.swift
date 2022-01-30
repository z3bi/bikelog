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
    @Published private(set) var isLoading: Bool = false
    private(set) var unit: UnitLength
    
    var sort: WorkoutSort = .date {
        didSet {
            setWorkouts(workouts)
        }
    }
    
    @AppStorage(DefaultKey.activity.rawValue)
    var activity: Activity = .cycling {
        didSet {
            if activity != oldValue {
                fetchWorkouts()
            }
        }
    }
    
    var healthProvider: HealthProvider
    
    init(healthProvider: HealthProvider) {
        self.healthProvider = healthProvider
        self.unit = Locale.current.distanceUnit()
        
        healthProvider.workoutsPublisher().sink { [weak self] healthResult in
            self?.unit = healthResult.unit
            self?.setWorkouts(healthResult.workouts)
            self?.isLoading = healthResult.cached
        }.store(in: &cancellables)
    }
    
    var cancellables = [AnyCancellable]()

    func fetchWorkouts() {
        workouts = []
        isLoading = true
        Task {
            await healthProvider.monitorWorkouts(activity: activity)
        }
    }
    
    // MARK: Internal

    private func setWorkouts(_ newWorkouts: [Workout]) {
        workouts = sort.sortedWorkouts(newWorkouts)
    }
}
