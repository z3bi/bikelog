//
//  HealthKitProvider.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/13/22.
//

import Foundation
import HealthKit
import Combine

class HealthKitProvider: HealthProvider {

    let store = HKHealthStore()

    let healthTypes: Set = [HKWorkoutType.workoutType(),
                            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
                            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                            HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!]
    
    enum HealthDataError: Error {
        case unavailableOnDevice
        case authorizationRequestError
        case queryError
    }
    
    func requestAuthorization() async {
        do {
            try await store.requestAuthorization(toShare: [], read: healthTypes)
        } catch {
            print("Error requesting HealthKit authorization \(error)")
        }
    }
    
    func queryWorkouts(activity: HKWorkoutActivityType) async -> [HKWorkout] {
        let type = HKWorkoutType.workoutType()
        let minDistance = HKQuantity(unit: HKUnit.meter(), doubleValue: 1)
        let predicate = NSPredicate(format: "%K > %@ && %K == %d", HKPredicateKeyPathWorkoutTotalDistance, minDistance, HKPredicateKeyPathWorkoutType, activity.rawValue)
        let sort = [NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)]
        
        return await withCheckedContinuation { continuation in
            let workoutQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: sort) { (query, samples, error) in
                guard let samples = samples as? [HKWorkout] else {
                    continuation.resume(with: .success([]))
                    return
                }
                continuation.resume(with: .success(samples))
            }
            store.execute(workoutQuery)
        }
    }
    
    func preferredUnit(for type: HKQuantityType) async -> HKUnit? {
        do {
            let units = try await store.preferredUnits(for: [type])
            return units[type]
        } catch {
            print("Error retrieving preferredUnits \(error)")
            return nil
        }
    }
    
    func fetchWorkouts(activity: WorkoutActivity) async -> (workouts: [Workout], unit: UnitLength) {
        await requestAuthorization()
        async let fetchWorkouts = queryWorkouts(activity: activity.hkActivityType)
        async let fetchUnit = preferredUnit(for: HKWorkout.distanceType(for: activity.hkActivityType))
        let (hkWorkouts, hkUnit) = await (fetchWorkouts, fetchUnit)
        guard let hkUnit = hkUnit else {
            return (workouts: [], unit: Locale.current.distanceUnit())
        }

        let workouts = hkWorkouts.compactMap { Workout(hkWorkout: $0, hkUnit: hkUnit) }
        let unit = hkUnit.lengthUnit()
        return (workouts: workouts, unit: unit)
    }
}

