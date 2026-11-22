import XCTest
@testable import BikeLog

final class WorkoutManagerTests: XCTestCase {
    @MainActor
    func testSupersededLoadCannotReplaceWorkoutsOrStopCurrentLoad() async throws {
        let cyclingStarted = expectation(description: "Cycling load suspended")
        let runningStarted = expectation(description: "Running load suspended")
        let provider = SuspendedHealthProvider { activity in
            switch activity {
            case .cycling: cyclingStarted.fulfill()
            case .running: runningStarted.fulfill()
            case .walking: XCTFail("Unexpected walking load")
            }
        }
        let suite = UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let manager = WorkoutManager(healthProvider: provider, defaults: defaults)

        let cycling = Task { await manager.monitorWorkouts(for: .cycling) }
        defer { cycling.cancel() }
        await fulfillment(of: [cyclingStarted], timeout: 2)

        manager.activity = .running
        let running = Task { await manager.monitorWorkouts(for: .running) }
        defer { running.cancel() }
        await fulfillment(of: [runningStarted], timeout: 2)

        let oldWorkout = makeWorkout(activity: .cycling)
        try provider.complete(with: oldWorkout)
        await cycling.value

        XCTAssertTrue(manager.workouts.isEmpty)
        XCTAssertTrue(manager.isLoading)

        let selectedWorkout = makeWorkout(activity: .running)
        try provider.complete(with: selectedWorkout)
        await running.value

        XCTAssertEqual(manager.workouts, [selectedWorkout])
        XCTAssertFalse(manager.isLoading)
    }

    @MainActor
    func testCancelledLoadIgnoresLateWorkout() async throws {
        let started = expectation(description: "Cycling load suspended")
        let provider = SuspendedHealthProvider { _ in started.fulfill() }
        let suite = UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let manager = WorkoutManager(healthProvider: provider, defaults: defaults)

        let load = Task { await manager.monitorWorkouts(for: .cycling) }
        defer { load.cancel() }
        await fulfillment(of: [started], timeout: 2)

        load.cancel()
        try provider.complete(with: makeWorkout(activity: .cycling))
        await load.value

        XCTAssertTrue(manager.workouts.isEmpty)
        XCTAssertFalse(manager.isLoading)
    }

    @MainActor
    func testRetryPreservesLoadedWorkoutsUntilSuccessfulRefresh() async throws {
        let cached = makeWorkout(activity: .cycling)
        let provider = RetryingHealthProvider(cachedWorkout: cached)
        let suite = UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let manager = WorkoutManager(healthProvider: provider, defaults: defaults)

        await manager.monitorWorkouts(for: .cycling)
        XCTAssertEqual(manager.refreshState, .failed)
        XCTAssertEqual(manager.workouts, [cached])

        let request = manager.refreshRequestID
        manager.retryRefresh()
        XCTAssertNotEqual(manager.refreshRequestID, request)
        XCTAssertTrue(manager.isLoading)
        await manager.monitorWorkouts(for: .cycling)
        XCTAssertEqual(manager.refreshState, .failed)
        XCTAssertEqual(manager.workouts, [cached])

        manager.retryRefresh()
        await manager.monitorWorkouts(for: .cycling)
        XCTAssertEqual(manager.refreshState, .ready)
        XCTAssertTrue(manager.workouts.isEmpty)
    }

    private func makeWorkout(activity: Activity) -> Workout {
        Workout(id: UUID(),
                startDate: Date(timeIntervalSince1970: 0),
                endDate: Date(timeIntervalSince1970: 600),
                activity: activity,
                duration: 600,
                distance: Measurement(value: 1, unit: .miles))
    }

    @MainActor
    private final class RetryingHealthProvider: HealthProvider {
        let cachedWorkout: Workout
        private var attempts = 0

        func details(for workout: Workout) async throws -> WorkoutDetails { WorkoutDetails() }

        init(cachedWorkout: Workout) {
            self.cachedWorkout = cachedWorkout
        }

        func monitorWorkouts(activity: Activity, onResult: @MainActor (HealthResult) -> Void) async throws {
            attempts += 1
            onResult(HealthResult(workouts: attempts == 1 ? [cachedWorkout] : [], unit: .miles, cached: true))
            if attempts < 3 { throw CocoaError(.fileReadUnknown) }
            onResult(HealthResult(workouts: [], unit: .miles, cached: false))
        }
    }
}

@MainActor
private final class SuspendedHealthProvider: HealthProvider {
    private let onStart: (Activity) -> Void
    private var pending: [Activity: CheckedContinuation<HealthResult, Never>] = [:]

    init(onStart: @escaping (Activity) -> Void) {
        self.onStart = onStart
    }

    func details(for workout: Workout) async throws -> WorkoutDetails { WorkoutDetails() }

    func monitorWorkouts(activity: Activity, onResult: @MainActor (HealthResult) -> Void) async throws {
        let result = await withCheckedContinuation { continuation in
            pending[activity] = continuation
            onStart(activity)
        }
        onResult(result)
    }

    func complete(with workout: Workout) throws {
        let continuation = try XCTUnwrap(pending.removeValue(forKey: workout.activity))
        continuation.resume(returning: HealthResult(workouts: [workout], unit: .miles, cached: false))
    }
}
