//
//  ExerciseLog.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import SwiftUI
import HealthKit

struct ExerciseLog: View {
    @ObservedObject var healthData: WorkoutManager
    
    init(healthProvider: HealthProvider) {
        healthData = WorkoutManager(healthProvider: healthProvider)
    }

    var body: some View {
        NavigationView {
            List {
                Picker("Sort", selection: $healthData.sort) {
                    ForEach(WorkoutSort.allCases, id: \.self) {
                        Text($0.name)
                    }
                }
                .pickerStyle(.segmented)

                ForEach(healthData.workouts) {
                    WorkoutRow(workout: $0)
                }
            }
            .listStyle(.plain)
            .task {
                await healthData.fetchWorkouts()
            }
            .navigationTitle(healthData.type.name)
            .toolbar {
                ToolbarItem {
                    Menu("Activity") {
                        Picker(selection: $healthData.type, label: Text("Activity")) {
                            ForEach(WorkoutType.allCases, id: \.self) { type in
                                Text(type.name)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseLog(healthProvider: MockHealthProvider())
    }
}
