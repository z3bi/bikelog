//
//  WorkoutDetail.swift
//  BikeLog
//
//  Created by Ameir Al-Zoubi on 1/19/22.
//

import SwiftUI
import OSLog

struct WorkoutDetail: View {
    private enum Destination: Hashable {
        case route
    }

    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale
    @State private var details: WorkoutDetails?
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var attempt = 0

    let workout: Workout
    let unit: UnitLength
    let loadDetails: @MainActor (Workout) async throws -> WorkoutDetails

    var body: some View {
        let model = WorkoutViewModel(workout: workout, unit: unit)
        let elapsed = workout.endDate.timeIntervalSince(workout.startDate)
        let dateFormat = Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone)
        let startTime = dateFormat.hour().minute()
        let endTime = calendar.isDate(workout.startDate, inSameDayAs: workout.endDate)
            ? startTime : startTime.month().day().year()

        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.startDate, format: dateFormat.weekday(.wide).month(.wide).day().year())
                        .workoutDetailValueStyle()
                    Text("\(workout.startDate.formatted(startTime)) – \(workout.endDate.formatted(endTime))")
                        .workoutDetailValueStyle()
                }
                .listRowBackground(Color.Theme.appBackground)
                
                WorkoutDetailValueRow("Distance", value: model.formattedDistance)
                WorkoutDetailValueRow("Duration", value: model.formattedDuration)
                if workout.duration > 0 {
                    WorkoutDetailValueRow("Average Speed", value: model.formattedSpeed)
                }
                if elapsed - workout.duration >= 60 {
                    let range = workout.startDate..<workout.endDate
                    WorkoutDetailValueRow("Elapsed Time", value: range.formatted(
                        .components(style: .condensedAbbreviated, fields: [.hour, .minute])
                    ))
                }
                if let details {
                    if let gain = details.elevationGain {
                        let elevationUnit: UnitLength = unit == .miles ? .feet : .meters
                        WorkoutDetailValueRow("Elevation Gain", value: gain.converted(to: elevationUnit)
                            .formatted(LengthFormat.lengthFormat(fractions: 0)))
                    }
                    if !details.route.isEmpty {
                        NavigationLink(value: Destination.route) {
                            Text("Route").workoutDetailValueStyle()
                        }
                        .listRowBackground(Color.Theme.appBackground)
                    }
                }
            } header: {
                Text("Overview")
                    .font(.system(.body, design: .rounded).weight(.bold))
                    .foregroundStyle(Color.Theme.accentSecondary)
            }

            if let details {
                let splits = SpeedSplit.calculate(samples: details.distanceSamples, splitLength: unit.splitLength,
                                                  workoutStart: workout.startDate, workoutEnd: workout.endDate)
                WorkoutDetailCharts(details: details, speedSplits: splits, unit: unit)
            }

            if isLoading {
                ProgressView("Loading workout details...")
            } else if loadFailed || details?.hasPartialFailure == true {
                Label("Some workout details couldn’t load", systemImage: "exclamationmark.circle")
                Button("Retry") { attempt += 1 }
            }
        }
        .themedList()
        .navigationTitle(Text("Cycling Workout"))
        .navigationDestination(for: Destination.self) { destination in
            switch destination {
            case .route:
                if let details, !details.route.isEmpty {
                    WorkoutRouteMap(segments: details.route)
                } else {
                    ContentUnavailableView("Route Unavailable", systemImage: "map")
                }
            }
        }
        .task(id: attempt) { await load() }
    }

    private func load() async {
        isLoading = true
        loadFailed = false
        do {
            let result = try await loadDetails(workout)
            try Task.checkCancellation()
            details = result
        } catch {
            guard !Task.isCancelled else { return }
            Logger.workoutDetail.error("Could not load workout details: \(error.localizedDescription, privacy: .private)")
            loadFailed = true
        }
        isLoading = false
    }
}

#Preview("Loaded", traits: .app) {
    let provider = MockHealthProvider()
    NavigationStack {
        WorkoutDetail(workout: MockHealthProvider.sampleWorkout, unit: .miles, loadDetails: provider.details(for:))
    }
}

#Preview("Loading Details", traits: .app) {
    let provider = MockHealthProvider(detailsScenario: .loading)
    NavigationStack {
        WorkoutDetail(workout: MockHealthProvider.sampleWorkout, unit: .miles, loadDetails: provider.details(for:))
    }
}

#Preview("Load Failed", traits: .app) {
    let provider = MockHealthProvider(detailsScenario: .failed)
    NavigationStack {
        WorkoutDetail(workout: MockHealthProvider.sampleWorkout, unit: .miles, loadDetails: provider.details(for:))
    }
}

#Preview("Partial Failure", traits: .app) {
    let provider = MockHealthProvider(detailsScenario: .partial)
    NavigationStack {
        WorkoutDetail(workout: MockHealthProvider.sampleWorkout, unit: .miles, loadDetails: provider.details(for:))
    }
}

#Preview("Minimal Ride", traits: .app) {
    let provider = MockHealthProvider(detailsScenario: .minimal)
    NavigationStack {
        WorkoutDetail(workout: MockHealthProvider.sampleWorkout, unit: .miles, loadDetails: provider.details(for:))
    }
}

#Preview("Metric", traits: .app) {
    let provider = MockHealthProvider(unit: .kilometers)
    NavigationStack {
        WorkoutDetail(workout: MockHealthProvider.sampleWorkout, unit: .kilometers, loadDetails: provider.details(for:))
    }
}
