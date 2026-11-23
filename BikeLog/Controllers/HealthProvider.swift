//
//  HealthProvider.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

protocol HealthProvider: Sendable {
    /// Emits complete workout snapshots: the cached copy first, then live updates until cancelled.
    func workoutUpdates() -> AsyncThrowingStream<HealthResult, Error>

    func details(for workout: Workout) async throws -> WorkoutDetails
}
