//
//  HealthProvider.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

protocol HealthProvider {
    @MainActor
    func monitorWorkouts(activity: Activity, onResult: @MainActor (HealthResult) -> Void) async throws

    @MainActor
    func details(for workout: Workout) async throws -> WorkoutDetails
}
