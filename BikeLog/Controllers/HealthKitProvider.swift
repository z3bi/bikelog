//
//  HealthKitProvider.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/13/22.
//

import Foundation
import HealthKit
import OSLog

final class HealthKitProvider: HealthProvider {
    enum ProviderError: LocalizedError {
        case healthDataUnavailable

        var errorDescription: String? {
            String(localized: "Health data is not available on this device.")
        }
    }

    let store: HKHealthStore
    private let cache = WorkoutCache()
    private let authorization: HealthAuthorization

    init() {
        let store = HKHealthStore()
        self.store = store
        authorization = HealthAuthorization {
            guard HKHealthStore.isHealthDataAvailable() else { throw ProviderError.healthDataUnavailable }
            try await store.requestAuthorization(toShare: [], read: HealthTypes.read)
        }
    }

    func authorize() async throws {
        try await authorization.authorize()
    }

    func workoutUpdates() -> AsyncThrowingStream<HealthResult, Error> {
        let (stream, continuation) = AsyncThrowingStream.makeStream(of: HealthResult.self,
                                                                    bufferingPolicy: .bufferingNewest(1))
        let task = Task {
            do {
                try await monitorWorkouts { continuation.yield($0) }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
        continuation.onTermination = { _ in task.cancel() }
        return stream
    }

    private func monitorWorkouts(_ send: (HealthResult) -> Void) async throws {
        var state: HealthResult
        do {
            state = try await cache.load() ?? .empty
        } catch {
            Logger.healthKit.error("Could not read the workout cache; will rebuild: \(error.localizedDescription, privacy: .private)")
            state = .empty
        }
        try Task.checkCancellation()
        send(state)

        try await authorize()
        let unit = await preferredUnit()
        try Task.checkCancellation()
        if unit != state.unit {
            state.unit = unit
            send(state)
        }

        let predicate = HKSamplePredicate.workout(HKQuery.predicateForWorkouts(with: .cycling))
        let query = HKAnchoredObjectQueryDescriptor(predicates: [predicate], anchor: state.anchor)
        for try await result in query.results(for: store) {
            try Task.checkCancellation()
            state = state.applying(added: result.addedSamples.compactMap(Workout.init(hkWorkout:)),
                                   deleted: result.deletedObjects.map(\.uuid),
                                   newAnchor: result.newAnchor)
            send(state)
            do {
                try await cache.save(state)
            } catch {
                Logger.healthKit.error("Could not save the workout cache: \(error.localizedDescription, privacy: .private)")
            }
        }
    }

    private func preferredUnit() async -> UnitLength {
        do {
            let units = try await store.preferredUnits(for: [HealthTypes.cyclingDistance])
            if let unit = units[HealthTypes.cyclingDistance]?.lengthUnit {
                return unit
            }
        } catch {
            if !Task.isCancelled {
                Logger.healthKit.error("Could not read the preferred unit: \(error.localizedDescription, privacy: .private)")
            }
        }
        return Locale.current.distanceUnit
    }
}
