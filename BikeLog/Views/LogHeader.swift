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

            Picker("Sort", selection: $manager.sort) {
                ForEach(WorkoutSort.allCases, id: \.self) {
                    Text($0.name)
                }
            }
            .pickerStyle(.segmented)
            .padding(.top, 8)
            if manager.isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Fetching workouts...")
                        .foregroundStyle(.gray)
                }
                .padding(.top, 22)
            } else if manager.refreshState == .failed {
                WorkoutListStatus(manager: manager)
            }
        }
    }
}
