//
//  WorkoutManager.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class WorkoutManager {
    enum RefreshState {
        case loading
        case ready
        case failed
    }

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "BikeLog", category: "Workouts")
    private let healthProvider: HealthProvider
    private let defaults: UserDefaults
    @ObservationIgnored private var activeLoad: UUID?
    @ObservationIgnored private var hasLiveSnapshot = false

    private(set) var workouts: [Workout] = []
    private(set) var refreshState: RefreshState = .loading
    private(set) var refreshRequestID = UUID()
    var isLoading: Bool { refreshState == .loading }
    private(set) var unit: UnitLength
    
    var sort: WorkoutSort = .date {
        didSet {
            setWorkouts(workouts)
        }
    }
    
    var activity: Activity {
        didSet {
            guard activity != oldValue else { return }
            activeLoad = nil
            hasLiveSnapshot = false
            workouts = []
            refreshState = .loading
            refreshRequestID = UUID()
            defaults.set(activity.rawValue, forKey: DefaultKey.activity.rawValue)
        }
    }

    init(healthProvider: HealthProvider, defaults: UserDefaults = .standard) {
        self.healthProvider = healthProvider
        self.defaults = defaults
        self.unit = Locale.current.distanceUnit()
        self.activity = defaults.string(forKey: DefaultKey.activity.rawValue)
            .flatMap(Activity.init(rawValue:)) ?? .cycling
    }

    func retryRefresh() {
        guard refreshState == .failed else { return }
        refreshState = .loading
        refreshRequestID = UUID()
    }

    func details(for workout: Workout) async throws -> WorkoutDetails {
        try await healthProvider.details(for: workout)
    }

    func monitorWorkouts(for activity: Activity) async {
        guard !Task.isCancelled, activity == self.activity else { return }
        let load = UUID()
        activeLoad = load
        let preserveDisplayedWorkouts = hasLiveSnapshot || !workouts.isEmpty
        refreshState = .loading
        defer {
            if activeLoad == load {
                activeLoad = nil
                if isLoading { refreshState = .ready }
            }
        }

        do {
            try await healthProvider.monitorWorkouts(activity: activity) { result in
                guard !Task.isCancelled, self.activeLoad == load else { return }
                if result.cached && preserveDisplayedWorkouts { return }
                self.unit = result.unit
                self.setWorkouts(result.workouts)
                if !result.cached {
                    self.hasLiveSnapshot = true
                    self.refreshState = .ready
                }
            }
        } catch {
            guard !Task.isCancelled, activeLoad == load else { return }
            refreshState = .failed
            Self.logger.error("Workout monitoring failed: \(error.localizedDescription, privacy: .private)")
        }
    }
    
    // MARK: Internal

    private func setWorkouts(_ newWorkouts: [Workout]) {
        workouts = sort.sortedWorkouts(newWorkouts)
    }
}
