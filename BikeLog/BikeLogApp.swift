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
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        let titleAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(resource: .Theme.primary)]
        navBarAppearance.titleTextAttributes = titleAttributes
        navBarAppearance.largeTitleTextAttributes = titleAttributes
  
        let navBarProxy = UINavigationBar.appearance()
        navBarProxy.standardAppearance = navBarAppearance
        navBarProxy.scrollEdgeAppearance = navBarAppearance
        navBarProxy.compactAppearance = navBarAppearance
        navBarProxy.compactScrollEdgeAppearance = navBarAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            ExerciseLog(workoutManager: workoutManager)
                .preferredColorScheme(.dark)
        }
    }
}
