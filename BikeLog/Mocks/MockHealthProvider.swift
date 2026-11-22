//
//  MockHealthProvider.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/13/22.
//

import CoreLocation
import Foundation

class MockHealthProvider: HealthProvider {
    
    init(unit: UnitLength = .miles) {
        self.unit = unit
    }
    
    let unit: UnitLength
    
    func generateWorkout(activity: Activity, dayOffset: Int = 1) -> Workout {
        let distance: Measurement<UnitLength>
        let duration: TimeInterval
        switch activity {
        case .cycling:
            distance = Measurement(value: Double.random(in: 15...30), unit: unit)
            let mph = Double.random(in: 10...20)
            duration = (distance.value / mph) * 60 * 60
        case .running:
            distance = Measurement(value: Double.random(in: 2...5), unit: unit)
            let mph = Double.random(in: 5...7)
            duration = (distance.value / mph) * 60 * 60
        case .walking:
            distance = Measurement(value: Double.random(in: 0.5...1.5), unit: unit)
            let mph = Double.random(in: 3...4)
            duration = (distance.value / mph) * 60 * 60
        }
        let start = Date().addingTimeInterval((-1 * (Double(dayOffset) * 60 * 60 * 24)) - Double.random(in: 60...9999))
        
        let end = start.addingTimeInterval(duration)
        
        return Workout(id: UUID(),
                       startDate: start,
                       endDate: end,
                       activity: activity,
                       duration: duration,
                       distance: distance)
    }
    
    func generateWorkouts(activity: Activity, range: ClosedRange<Int>) -> [Workout] {
        range.map { generateWorkout(activity: activity, dayOffset: $0) }
    }

    func details(for workout: Workout) async throws -> WorkoutDetails {
        let distances = (0..<48).map { _ in workout.distance.converted(to: .meters).value / 48 }
        let weights = distances.indices.map { 1 + 0.22 * cos(Double($0) / 3) }
        let weightSum = weights.reduce(0, +)
        var start = workout.startDate
        let samples = zip(distances, weights).map { meters, weight in
            let end = min(start + workout.duration * weight / weightSum, workout.endDate)
            defer { start = end }
            return MileSpeedSplit.DistanceSample(start: start, end: end, meters: meters)
        }
        let readings = (0..<24).map { index in
            WorkoutDetails.HeartRateReading(id: UUID(),
                                            time: workout.startDate + workout.duration * Double(index) / 24,
                                            beatsPerMinute: 125 + 19 * sin(Double(index) / 4))
        }
        let route = [
            CLLocationCoordinate2D(latitude: 37.7695, longitude: -122.4860),
            CLLocationCoordinate2D(latitude: 37.7691, longitude: -122.4803),
            CLLocationCoordinate2D(latitude: 37.7698, longitude: -122.4766),
            CLLocationCoordinate2D(latitude: 37.7713, longitude: -122.4722)
        ]
        return WorkoutDetails(route: [route], heartRate: readings,
                              averageHeartRate: readings.map(\.beatsPerMinute).reduce(0, +) / Double(readings.count),
                              peakHeartRate: readings.map(\.beatsPerMinute).max(),
                              activeCalories: workout.duration / 60 * 6,
                              elevationGain: Measurement(value: 85, unit: .meters),
                              mileSpeeds: MileSpeedSplit.calculate(samples: samples, workoutStart: workout.startDate,
                                                                   workoutEnd: workout.endDate))
    }
    
    func monitorWorkouts(activity: Activity, onResult: @MainActor (HealthResult) -> Void) async throws {
        let initialWorkouts = generateWorkouts(activity: activity, range: 50...100)
        onResult(HealthResult(workouts: initialWorkouts, unit: unit, cached: true))

        try await Task.sleep(for: .seconds(2))
        let newWorkouts = generateWorkouts(activity: activity, range: 10...13)
        onResult(HealthResult(workouts: initialWorkouts + newWorkouts, unit: unit, cached: false))
    }
}

extension WorkoutManager {
    static func mock(unit: UnitLength = .miles) -> WorkoutManager {
        WorkoutManager(healthProvider: MockHealthProvider(unit: unit))
    }
}
