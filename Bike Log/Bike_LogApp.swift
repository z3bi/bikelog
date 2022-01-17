//
//  Bike_LogApp.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import SwiftUI

@main
struct Bike_LogApp: App {
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(.Theme.orange)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(.Theme.orange)]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = UIColor(.Theme.orange)
    }
    
    var body: some Scene {
        WindowGroup {
            #if targetEnvironment(simulator)
                ExerciseLog(healthProvider: MockHealthProvider())
            #else
                ExerciseLog(healthProvider: HealthKitProvider())
            #endif
        }
    }
}
