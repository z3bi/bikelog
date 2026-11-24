//
//  MockHealthProvider.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/13/22.
//

import CoreLocation
import Foundation

/// Deterministic health data for the simulator and SwiftUI previews.
final class MockHealthProvider: HealthProvider {
    enum Scenario: Sendable {
        /// Cached snapshot, then a live snapshot with a few newer rides.
        case loaded
        /// Nothing cached and HealthKit never answers.
        case firstLaunch
        /// Cached snapshot shown while the live query never finishes.
        case refreshing
        /// HealthKit answers with no rides.
        case empty
        /// The query fails with nothing cached.
        case failed
        /// The query fails after the cached snapshot was shown.
        case failedWithCache
    }

    enum DetailsScenario: Sendable {
        case loaded
        /// Details never finish loading.
        case loading
        case failed
        /// Route and heart rate failed; distance samples loaded.
        case partial
        /// A ride without a route, heart rate, or elevation, such as an indoor ride.
        case minimal
    }

    struct MockError: LocalizedError {
        var errorDescription: String? { "Mock health data failed to load." }
    }

    let unit: UnitLength
    private let scenario: Scenario
    private let detailsScenario: DetailsScenario
    private let liveDelay: Duration
    private let workouts: [Workout]

    init(unit: UnitLength = .miles, scenario: Scenario = .loaded, detailsScenario: DetailsScenario = .loaded,
         liveDelay: Duration = .seconds(2)) {
        self.unit = unit
        self.scenario = scenario
        self.detailsScenario = detailsScenario
        self.liveDelay = liveDelay
        self.workouts = Self.sampleWorkouts()
    }

    func workoutUpdates() -> AsyncThrowingStream<HealthResult, Error> {
        let (stream, continuation) = AsyncThrowingStream.makeStream(of: HealthResult.self)
        let task = Task {
            do {
                try await emit(to: continuation)
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
        continuation.onTermination = { _ in task.cancel() }
        return stream
    }

    func details(for workout: Workout) async throws -> WorkoutDetails {
        switch detailsScenario {
        case .loaded:
            return Self.sampleDetails(for: workout)
        case .loading:
            try await Self.waitUntilCancelled()
            throw CancellationError()
        case .failed:
            throw MockError()
        case .partial:
            var details = Self.sampleDetails(for: workout)
            details.route = []
            details.heartRate = []
            details.averageHeartRate = nil
            details.peakHeartRate = nil
            details.hasPartialFailure = true
            return details
        case .minimal:
            return WorkoutDetails()
        }
    }

    private func emit(to continuation: AsyncThrowingStream<HealthResult, Error>.Continuation) async throws {
        let cached = HealthResult(workouts: Array(workouts.dropFirst(3)), unit: unit, cached: true)
        switch scenario {
        case .loaded:
            continuation.yield(cached)
            try await Task.sleep(for: liveDelay)
            continuation.yield(HealthResult(workouts: workouts, unit: unit, cached: false))
        case .firstLaunch:
            try await Self.waitUntilCancelled()
        case .refreshing:
            continuation.yield(cached)
            try await Self.waitUntilCancelled()
        case .empty:
            continuation.yield(HealthResult(workouts: [], unit: unit, cached: false))
        case .failed:
            throw MockError()
        case .failedWithCache:
            continuation.yield(cached)
            throw MockError()
        }
    }

    private static func waitUntilCancelled() async throws {
        while true {
            try await Task.sleep(for: .seconds(3600))
        }
    }
}

// MARK: - Sample data

extension MockHealthProvider {
    /// About two years of rides: frequent recent rides, then roughly one every ten days.
    static func sampleWorkouts(count: Int = 80, relativeTo now: Date = .now) -> [Workout] {
        (0..<count).map { index in
            let dayOffset = index < 12 ? index * 2 : 25 + (index - 12) * 10
            let miles = 12 + 18 * (0.5 + 0.5 * sin(Double(index) * 1.7))
            let mph = 11 + 7 * (0.5 + 0.5 * cos(Double(index) * 1.3))
            let duration = miles / mph * 3600
            let paused: TimeInterval = index.isMultiple(of: 4) ? 15 * 60 : 0
            let start = now.addingTimeInterval(-Double(dayOffset) * 86_400 - 5 * 3600)
            return Workout(id: sampleID(index),
                           startDate: start,
                           endDate: start + duration + paused,
                           duration: duration,
                           distance: Measurement(value: miles, unit: UnitLength.miles).converted(to: .meters))
        }
    }

    static var sampleWorkout: Workout {
        sampleWorkouts(count: 1)[0]
    }

    static let sampleRoute: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 37.7695, longitude: -122.5100),
        CLLocationCoordinate2D(latitude: 37.7699, longitude: -122.4980),
        CLLocationCoordinate2D(latitude: 37.7691, longitude: -122.4860),
        CLLocationCoordinate2D(latitude: 37.7698, longitude: -122.4766),
        CLLocationCoordinate2D(latitude: 37.7713, longitude: -122.4600),
        CLLocationCoordinate2D(latitude: 37.7740, longitude: -122.4540),
    ]

    /// A route split in two, as when GPS drops out mid-ride.
    static var sampleRouteSegments: [[CLLocationCoordinate2D]] {
        [Array(sampleRoute.prefix(3)), Array(sampleRoute.suffix(2))]
    }

    static func sampleDetails(for workout: Workout) -> WorkoutDetails {
        let distances = (0..<48).map { _ in workout.distance.converted(to: .meters).value / 48 }
        let weights = distances.indices.map { 1 + 0.22 * cos(Double($0) / 3) }
        let weightSum = weights.reduce(0, +)
        var start = workout.startDate
        let samples = zip(distances, weights).map { meters, weight in
            let end = min(start + workout.duration * weight / weightSum, workout.endDate)
            defer { start = end }
            return SpeedSplit.DistanceSample(start: start, end: end, meters: meters)
        }
        let readings = (0..<24).map { index in
            WorkoutDetails.HeartRateReading(id: sampleID(index),
                                            time: workout.startDate + workout.duration * Double(index) / 24,
                                            beatsPerMinute: 125 + 19 * sin(Double(index) / 4))
        }
        return WorkoutDetails(route: [sampleRoute], heartRate: readings,
                              averageHeartRate: readings.map(\.beatsPerMinute).reduce(0, +) / Double(readings.count),
                              peakHeartRate: readings.map(\.beatsPerMinute).max(),
                              activeCalories: workout.duration / 60 * 6,
                              elevationGain: Measurement(value: 85, unit: .meters),
                              distanceSamples: samples)
    }

    private static func sampleID(_ index: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", index))!
    }
}

extension WorkoutManager {
    static func mock(unit: UnitLength = .miles) -> WorkoutManager {
        WorkoutManager(healthProvider: MockHealthProvider(unit: unit))
    }

    /// A manager whose first `monitorWorkouts()` call settles into the scenario's state without delay.
    static func preview(_ scenario: MockHealthProvider.Scenario = .loaded, unit: UnitLength = .miles) -> WorkoutManager {
        WorkoutManager(healthProvider: MockHealthProvider(unit: unit, scenario: scenario, liveDelay: .zero))
    }
}
