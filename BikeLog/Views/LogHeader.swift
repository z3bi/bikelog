//
//  LogHeader.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/16/22.
//

import SwiftUI

struct LogHeader: View {
    @Environment(\.calendar) private var calendar
    @Bindable var manager: WorkoutManager
    let showDestination: (ExerciseLog.Destination) -> Void

    private func summary(for period: StatisticalPeriod, at date: Date) -> StatsViewModel {
        StatsViewModel(date: date,
                       period: period,
                       unit: manager.unit,
                       workouts: manager.workouts,
                       calendar: calendar)
    }

    private func destination(for summary: StatsViewModel) -> ExerciseLog.Destination {
        switch summary.period {
        case .all:
            .yearlyTotals
        case .year:
            .monthlyTotals(year: summary.dateInterval.start)
        case .month, .week:
            .periodWorkouts(period: summary.period, interval: summary.dateInterval)
        }
    }
    
    var body: some View {
        let date = Date.now

        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(StatisticalPeriod.allCases, id: \.self) { period in
                    let model = summary(for: period, at: date)
                    Button {
                        showDestination(destination(for: model))
                    } label: {
                        HStack(spacing: 12) {
                            WorkoutSummaryRow(title: model.title,
                                              distance: model.totalDistance(),
                                              count: model.workoutCount())
                            Image(systemName: "chevron.forward")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.tertiary)
                                .accessibilityHidden(true)
                        }
                        .padding(.vertical, 5)
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if manager.isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(Color.Theme.accentSecondary)
                    Text("Fetching workouts...")
                        .foregroundStyle(Color.Theme.accentSecondary)
                }
                .padding(.vertical, 8)
            } else if manager.refreshState == .failed {
                WorkoutListStatus(manager: manager)
            }

            Picker("Sort", selection: $manager.sort) {
                ForEach(WorkoutSort.allCases, id: \.self) {
                    Text($0.name)
                }
            }
            .pickerStyle(.segmented)
            .padding(.top, 8)
            .opacity(manager.workouts.isEmpty ? 0 : 1)
        }
    }
}

#Preview("Loaded", traits: .app) {
    let manager = WorkoutManager.preview(.loaded)
    List {
        LogHeader(manager: manager) { _ in }
            .listRowBackground(Color.Theme.appBackground)
            .listRowSeparator(.hidden)
    }
    .themedList()
    .monitoring(manager)
}

#Preview("Loading", traits: .app) {
    let manager = WorkoutManager.preview(.firstLaunch)
    List {
        LogHeader(manager: manager) { _ in }
            .listRowBackground(Color.Theme.appBackground)
            .listRowSeparator(.hidden)
    }
    .themedList()
    .monitoring(manager)
}

#Preview("Error", traits: .app) {
    let manager = WorkoutManager.preview(.failed)
    List {
        LogHeader(manager: manager) { _ in }
            .listRowBackground(Color.Theme.appBackground)
            .listRowSeparator(.hidden)
    }
    .themedList()
    .monitoring(manager)
}
