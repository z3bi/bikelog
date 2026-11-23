import CoreLocation
import HealthKit
import OSLog

extension HealthKitProvider {
    func details(for workout: Workout) async throws -> WorkoutDetails {
        try await authorize()
        let match = HKQuery.predicateForObject(with: workout.id)
        let query = HKSampleQueryDescriptor(predicates: [.workout(match)], sortDescriptors: [], limit: 1)
        guard let record = try await query.result(for: store).first else {
            return WorkoutDetails()
        }
        try Task.checkCancellation()

        let heartRateType = HealthTypes.heartRate
        async let route = detailSection("route") { try await self.routeSegments(for: record) }
        async let heartRate = detailSection("heart rate") {
            try await self.heartRateSamples(of: heartRateType, for: record)
        }
        async let distance = detailSection("distance") {
            try await self.distanceSamples(of: HealthTypes.cyclingDistance, for: record)
        }
        let (routeResult, heartRateResult, distanceResult) = try await (route, heartRate, distance)
        try Task.checkCancellation()

        let bpm = HKUnit.count().unitDivided(by: .minute())
        let readings = (heartRateResult ?? []).compactMap { sample -> WorkoutDetails.HeartRateReading? in
            let value = sample.quantity.doubleValue(for: bpm)
            guard value.isFinite, value > 0 else { return nil }
            return .init(id: sample.uuid, time: sample.startDate, beatsPerMinute: value)
        }
        let statistics = record.statistics(for: heartRateType)
        let measuredAverage = statistics?.averageQuantity()?.doubleValue(for: bpm)
        let measuredPeak = statistics?.maximumQuantity()?.doubleValue(for: bpm)
        let sampledAverage = readings.isEmpty ? nil : readings.map(\.beatsPerMinute).reduce(0, +) / Double(readings.count)
        let elevation = record.metadata?[HKMetadataKeyElevationAscended] as? HKQuantity
        let meters = elevation?.doubleValue(for: .meter())
        return WorkoutDetails(
            route: routeResult ?? [],
            heartRate: readings,
            averageHeartRate: measuredAverage ?? sampledAverage,
            peakHeartRate: measuredPeak ?? readings.map(\.beatsPerMinute).max(),
            activeCalories: record.statistics(for: HealthTypes.activeEnergy)?
                .sumQuantity()?.doubleValue(for: .kilocalorie()),
            elevationGain: meters.map { Measurement(value: $0, unit: .meters) },
            distanceSamples: distanceResult ?? [],
            hasPartialFailure: routeResult == nil || heartRateResult == nil || distanceResult == nil
        )
    }

    private func heartRateSamples(of type: HKQuantityType, for workout: HKWorkout) async throws -> [HKQuantitySample] {
        let predicate = HKQuery.predicateForObjects(from: workout)
        let query = HKSampleQueryDescriptor(predicates: [.quantitySample(type: type, predicate: predicate)],
                                            sortDescriptors: [SortDescriptor(\.startDate)])
        return try await query.result(for: store)
    }

    private func distanceSamples(of type: HKQuantityType, for workout: HKWorkout) async throws -> [SpeedSplit.DistanceSample] {
        let predicate = HKQuery.predicateForObjects(from: workout)
        let query = HKQuantitySeriesSampleQueryDescriptor(predicate: .quantitySample(type: type, predicate: predicate))
        var samples: [SpeedSplit.DistanceSample] = []
        for try await result in query.results(for: store) {
            try Task.checkCancellation()
            samples.append(.init(start: result.dateInterval.start, end: result.dateInterval.end,
                                 meters: result.quantity.doubleValue(for: .meter())))
        }
        return samples
    }

    private func routeSegments(for workout: HKWorkout) async throws -> [[CLLocationCoordinate2D]] {
        let predicate = HKQuery.predicateForObjects(from: workout)
        let query = HKSampleQueryDescriptor(predicates: [.workoutRoute(predicate)],
                                            sortDescriptors: [SortDescriptor(\.startDate)])
        var segments: [[CLLocationCoordinate2D]] = []
        for route in try await query.result(for: store) {
            var coordinates: [CLLocationCoordinate2D] = []
            for try await location in HKWorkoutRouteQueryDescriptor(route).results(for: store) {
                try Task.checkCancellation()
                if location.horizontalAccuracy >= 0, CLLocationCoordinate2DIsValid(location.coordinate) {
                    coordinates.append(location.coordinate)
                }
            }
            if coordinates.count >= 2 { segments.append(coordinates) }
        }
        return segments
    }

    private func detailSection<Value: Sendable>(_ name: String, load: @Sendable () async throws -> Value) async throws -> Value? {
        do {
            return try await load()
        } catch {
            try Task.checkCancellation()
            Logger.workoutDetail.error("Could not load \(name) for workout detail: \(error.localizedDescription, privacy: .private)")
            return nil
        }
    }
}
