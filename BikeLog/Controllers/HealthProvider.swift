//
//  HealthProvider.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import Foundation
import HealthKit
import Combine

protocol HealthProvider {
    func fetchWorkouts(activity: WorkoutActivity) async -> (workouts: [Workout], unit: UnitLength)
}
