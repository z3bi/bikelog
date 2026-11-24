//
//  BikeLogApp.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import SwiftUI

@main
struct BikeLogApp: App {
    
#if targetEnvironment(simulator)
    @State private var workoutManager = WorkoutManager.mock()
#else
    @State private var workoutManager = WorkoutManager(healthProvider: HealthKitProvider())
#endif
    
    init() {
        AppAppearance.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ExerciseLog(workoutManager: workoutManager)
                .appColorScheme()
        }
    }
}
