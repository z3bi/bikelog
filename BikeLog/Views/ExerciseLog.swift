//
//  ExerciseLog.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import SwiftUI

struct ExerciseLog: View {
    enum Destination: Hashable {
        case yearlyTotals
        case monthlyTotals(year: Date)
        case periodWorkouts(period: StatisticalPeriod, interval: DateInterval)
    }

    @State private var path = NavigationPath()
    @Bindable var workoutManager: WorkoutManager

    var body: some View {
        NavigationStack(path: $path) {
            List {
                LogHeader(manager: workoutManager) { destination in
                    path.append(destination)
                }
                .listRowBackground(Color.Theme.appBackground)
                .listRowSeparator(.hidden)
                
                WorkoutRows(workouts: workoutManager.workouts, unit: workoutManager.unit)
                    .listRowBackground(Color.Theme.appBackground)
            }
            .themedList()
            .navigationDestination(for: Workout.self) { workout in
                WorkoutDetail(workout: workout, unit: workoutManager.unit, loadDetails: workoutManager.details(for:))
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .yearlyTotals:
                    YearlyTotalsView(manager: workoutManager)
                case .monthlyTotals(let year):
                    MonthlyTotalsView(year: year, manager: workoutManager)
                case .periodWorkouts(let period, let interval):
                    PeriodWorkoutsView(period: period, interval: interval, manager: workoutManager)
                }
            }
            .navigationTitle("Cycling Workouts")
        }
        .task(id: workoutManager.refreshRequestID) {
            await workoutManager.monitorWorkouts()
        }
    }
}

#Preview {
    ExerciseLog(workoutManager: WorkoutManager.mock())
}
