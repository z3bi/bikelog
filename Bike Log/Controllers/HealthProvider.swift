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
    func fetchWorkouts(type: WorkoutType) async -> (workouts: [Workout], unit: UnitLength)
}
