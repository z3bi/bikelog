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
    let publisher = CurrentValueSubject<HealthResult, Never>(.empty)
    var updateTask: Task<(), Error>?
    
    let healthTypes: Set = [HKWorkoutType.workoutType(),
                            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
                            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                            HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!]
    
    func requestAuthorization() async {
        do {
            try await store.requestAuthorization(toShare: [], read: healthTypes)
        } catch {
            print("Error requesting HealthKit authorization \(error)")
        }
    }

    func queryWorkouts(activity: Activity) {
        updateTask?.cancel()

        let activityPredicate = HKSamplePredicate.workout(HKQuery.predicateForWorkouts(with: activity.hkActivityType))
        let query = HKAnchoredObjectQueryDescriptor(predicates: [activityPredicate], anchor: publisher.value.anchor)
        let updatingResults = query.results(for: store)

        updateTask = Task {
            for try await newResult in updatingResults {
                publishResult(newResult, activity: activity)
            }
        }
    }
    
    private func publishResult(_ result: HKAnchoredObjectQueryDescriptor<HKWorkout>.Result, activity: Activity) {
        let unit = publisher.value.unit
        let newWorkouts = result.addedSamples.compactMap { Workout(hkWorkout: $0, hkUnit: unit.hkUnit()) }
        let deletedIDs = result.deletedObjects.map { $0.uuid }
        let validWorkouts = publisher.value.workouts.filter { !deletedIDs.contains($0.id) }
        let workouts = Array(Set(validWorkouts + newWorkouts))
        
        let newState = HealthResult(workouts: workouts,
                                    unit: publisher.value.unit,
                                    cached: false,
                                    anchor: result.newAnchor)
        publisher.value = newState
        newState.save(for: activity)
    }
    
    func preferredUnit(for type: HKQuantityType) async -> HKUnit {
        do {
            let units = try await store.preferredUnits(for: [type])
            if let unit = units[type] {
                return unit
            }
        } catch {
            print("Error retrieving preferredUnits \(error)")
        }
        
        return Locale.current.distanceUnit().hkUnit()
    }
    
    func monitorWorkouts(activity: Activity) async {
        let cachedResult = try? await HealthResult.load(activity: activity)
        publisher.value = cachedResult ?? .empty

        await requestAuthorization()
        let hkUnit = await preferredUnit(for: HKWorkout.distanceType(for: activity.hkActivityType))
        let unit = hkUnit.lengthUnit()

        if unit != publisher.value.unit {
            let workouts = Workout.updateWorkouts(publisher.value.workouts, unit: unit)
            let updatedResult = HealthResult(workouts: workouts, unit: unit, cached: true, anchor: cachedResult?.anchor)
            publisher.value = updatedResult
        }
        
        queryWorkouts(activity: activity)
    }
    
    func workoutsPublisher() -> AnyPublisher<HealthResult, Never> {
        publisher
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

