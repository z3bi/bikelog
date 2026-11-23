//
//  HealthKitProvider.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/13/22.
//

import Foundation
import HealthKit
import OSLog

@MainActor
final class HealthKitProvider: HealthProvider {
    private static let logger = Logger(subsystem: "BikeLog", category: "HealthKit")
    private let cache = WorkoutCache()
    let store = HKHealthStore()
    
    let healthTypes: Set = [HKWorkoutType.workoutType(),
                            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
                            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                            HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!]
    
    private func applying(_ result: HKAnchoredObjectQueryDescriptor<HKWorkout>.Result, to state: HealthResult) -> HealthResult {
        let unit = state.unit.hkUnit()
        return state.applying(added: result.addedSamples.compactMap { Workout(hkWorkout: $0, hkUnit: unit) },
                              deleted: result.deletedObjects.map(\.uuid),
                              newAnchor: result.newAnchor)
    }
    
    func preferredUnit(for type: HKQuantityType) async -> HKUnit {
        do {
            let units = try await store.preferredUnits(for: [type])
            if let unit = units[type] {
                return unit
            }
        } catch {
            if !Task.isCancelled {
                Self.logger.error("Could not read the preferred unit: \(error.localizedDescription, privacy: .private)")
            }
        }
        
        return Locale.current.distanceUnit().hkUnit()
    }
    
    func monitorWorkouts(activity: Activity, onResult: @MainActor (HealthResult) -> Void) async throws {
        var state: HealthResult
        do {
            state = try await cache.load(for: activity) ?? .empty
        } catch {
            Self.logger.error("Could not read the workout cache; will rebuild: \(error.localizedDescription, privacy: .private)")
            state = .empty
        }
        try Task.checkCancellation()
        onResult(state)

        try await store.requestAuthorization(toShare: [], read: healthTypes)
        try Task.checkCancellation()
        let hkUnit = await preferredUnit(for: HKWorkout.cyclingDistanceType)
        try Task.checkCancellation()
        let unit = hkUnit.lengthUnit()

        if unit != state.unit {
            state.workouts = Workout.updateWorkouts(state.workouts, unit: unit)
            state.unit = unit
            onResult(state)
        }

        let predicate = HKSamplePredicate.workout(HKQuery.predicateForWorkouts(with: activity.hkActivityType))
        let query = HKAnchoredObjectQueryDescriptor(predicates: [predicate], anchor: state.anchor)
        for try await result in query.results(for: store) {
            try Task.checkCancellation()
            state = applying(result, to: state)
            onResult(state)
            do {
                try await cache.save(state, for: activity)
            } catch {
                Self.logger.error("Could not save the workout cache: \(error.localizedDescription, privacy: .private)")
            }
        }
    }
}

