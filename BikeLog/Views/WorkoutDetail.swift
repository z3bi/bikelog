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

    private static let logger = Logger(subsystem: "BikeLog", category: "Workout detail")

    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale
    @State private var details: WorkoutDetails?
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var attempt = 0

    let workout: Workout
    let loadDetails: @MainActor (Workout) async throws -> WorkoutDetails

    var body: some View {
        let model = WorkoutViewModel(workout: workout)
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
                    WorkoutDetailValueRow(workout.activity == .cycling ? "Average Speed" : "Average Pace",
                                          value: model.formattedSpeed)
                }
                if elapsed - workout.duration >= 60 {
                    let range = workout.startDate..<workout.endDate
                    WorkoutDetailValueRow("Elapsed Time", value: range.formatted(
                        .components(style: .condensedAbbreviated, fields: [.hour, .minute])
                    ))
                }
                if let details {
                    if let gain = details.elevationGain {
                        let elevationUnit: UnitLength = workout.distance.unit == .miles ? .feet : .meters
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
                WorkoutDetailCharts(details: details)
            }

            if isLoading {
                ProgressView("Loading workout details...")
            } else if loadFailed || details?.hasPartialFailure == true {
                Label("Some workout details couldn’t load", systemImage: "exclamationmark.circle")
                Button("Retry") { attempt += 1 }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.Theme.appBackground)
        .navigationTitle(Text("\(workout.activity.name) Workout"))
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
            Self.logger.error("Could not load workout details: \(error.localizedDescription, privacy: .private)")
            loadFailed = true
        }
        isLoading = false
    }
}

#Preview {
    let provider = MockHealthProvider()
    NavigationStack {
        WorkoutDetail(workout: provider.generateWorkout(activity: .cycling), loadDetails: provider.details(for:))
    }
}
