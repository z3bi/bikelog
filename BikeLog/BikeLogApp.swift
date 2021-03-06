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
    @StateObject var workoutManager: WorkoutManager = WorkoutManager.mock()
#else
    @StateObject var workoutManager: WorkoutManager = WorkoutManager(healthProvider: HealthKitProvider())
#endif
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(.Theme.orange)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(.Theme.orange)]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = UIColor(.Theme.orange)
    }
    
    var body: some Scene {
        WindowGroup {
            ExerciseLog(workoutManager: workoutManager)
        }
    }
}
