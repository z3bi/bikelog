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

    private let healthProvider: HealthProvider
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

    init(healthProvider: HealthProvider) {
        self.healthProvider = healthProvider
        self.unit = Locale.current.distanceUnit
    }

    func retryRefresh() {
        guard refreshState == .failed else { return }
        refreshState = .loading
        refreshRequestID = UUID()
    }

    func details(for workout: Workout) async throws -> WorkoutDetails {
        try await healthProvider.details(for: workout)
    }

    func monitorWorkouts() async {
        guard !Task.isCancelled else { return }
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
            for try await result in healthProvider.workoutUpdates() {
                guard !Task.isCancelled, activeLoad == load else { break }
                if result.cached && preserveDisplayedWorkouts { continue }
                unit = result.unit
                setWorkouts(result.workouts)
                if !result.cached {
                    hasLiveSnapshot = true
                    refreshState = .ready
                }
            }
        } catch {
            guard !Task.isCancelled, activeLoad == load else { return }
            refreshState = .failed
            Logger.workouts.error("Workout monitoring failed: \(error.localizedDescription, privacy: .private)")
        }
    }
    
    // MARK: Internal

    private func setWorkouts(_ newWorkouts: [Workout]) {
        workouts = sort.sortedWorkouts(newWorkouts)
    }
}
