//
//  ExerciseLog.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import SwiftUI
import HealthKit

struct ExerciseLog: View {
    
    @ObservedObject var workoutManager: WorkoutManager

    var body: some View {
        NavigationView {
            List {
                LogHeader(manager: workoutManager)
                    .listRowSeparator(.hidden)
                ForEach(workoutManager.workouts) { workout in
                    NavigationLink(destination: WorkoutDetail(workout: workout)) {
                        WorkoutRow(workout: workout)
                    }
                }
            }
            .listStyle(.plain)
            .task {
                print(">> running task")
                await workoutManager.fetchWorkouts()
            }
            .navigationTitle(workoutManager.activity.name)
            .toolbar {
                ToolbarItem {
                    Menu("Activity") {
                        Picker(selection: $workoutManager.activity, label: Text("Activity")) {
                            ForEach(WorkoutActivity.allCases, id: \.self) { activity in
                                Text(activity.name)
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
        ExerciseLog(workoutManager: WorkoutManager.mock())
    }
}
