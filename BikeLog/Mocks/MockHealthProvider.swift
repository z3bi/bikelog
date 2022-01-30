//
//  MockHealthProvider.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/13/22.
//

import Foundation
import Combine

class MockHealthProvider: HealthProvider {
    
    init(unit: UnitLength = .miles) {
        self.unit = unit
    }
    
    let unit: UnitLength
    let publisher = CurrentValueSubject<HealthResult, Never>(.empty)
    
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
    
    func monitorWorkouts(activity: Activity) {
        publisher.value = HealthResult(workouts: [], unit: unit, cached: true)
        let initialWorkouts = generateWorkouts(activity: activity, range: 50...100)
        publisher.value.workouts = initialWorkouts

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let newWorkouts = self.generateWorkouts(activity: activity, range: 10...13)
            let workouts = self.publisher.value.workouts + newWorkouts
            self.publisher.value = HealthResult(workouts: workouts, unit: self.unit, cached: false)
        }        
    }
    
    func workoutsPublisher() -> AnyPublisher<HealthResult, Never> {
        return publisher.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
}

extension WorkoutManager {
    static func mock(activity: Activity = .cycling, unit: UnitLength = .miles) -> WorkoutManager {
        WorkoutManager(healthProvider: MockHealthProvider(unit: unit))
    }
}
