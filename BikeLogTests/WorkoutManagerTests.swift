import Synchronization
import XCTest
@testable import BikeLog

final class WorkoutManagerTests: XCTestCase {
   

    @MainActor
    func testCancelledLoadIgnoresLateWorkout() async throws {
        let started = expectation(description: "Cycling load suspended")
        let provider = SuspendedHealthProvider { started.fulfill() }
        let manager = WorkoutManager(healthProvider: provider)

        let load = Task { await manager.monitorWorkouts() }
        defer { load.cancel() }
        await fulfillment(of: [started], timeout: 2)

        load.cancel()
        provider.complete(with: makeWorkout())
        await load.value

        XCTAssertTrue(manager.workouts.isEmpty)
        XCTAssertFalse(manager.isLoading)
    }

    @MainActor
    func testRetryPreservesLoadedWorkoutsUntilSuccessfulRefresh() async throws {
        let cached = makeWorkout()
        let provider = RetryingHealthProvider(cachedWorkout: cached)
        let manager = WorkoutManager(healthProvider: provider)

        await manager.monitorWorkouts()
        XCTAssertEqual(manager.refreshState, .failed)
        XCTAssertEqual(manager.workouts, [cached])

        let request = manager.refreshRequestID
        manager.retryRefresh()
        XCTAssertNotEqual(manager.refreshRequestID, request)
        XCTAssertTrue(manager.isLoading)
        await manager.monitorWorkouts()
        XCTAssertEqual(manager.refreshState, .failed)
        XCTAssertEqual(manager.workouts, [cached])

        manager.retryRefresh()
        await manager.monitorWorkouts()
        XCTAssertEqual(manager.refreshState, .ready)
        XCTAssertTrue(manager.workouts.isEmpty)
    }

    private func makeWorkout() -> Workout {
        Workout(id: UUID(),
                startDate: Date(timeIntervalSince1970: 0),
                endDate: Date(timeIntervalSince1970: 600),
                duration: 600,
                distance: Measurement(value: 1, unit: .miles))
    }

    private final class RetryingHealthProvider: HealthProvider {
        let cachedWorkout: Workout
        private let attempts = Mutex(0)

        init(cachedWorkout: Workout) {
            self.cachedWorkout = cachedWorkout
        }

        func details(for workout: Workout) async throws -> WorkoutDetails { WorkoutDetails() }

        func workoutUpdates() -> AsyncThrowingStream<HealthResult, Error> {
            let attempt = attempts.withLock { attempts in
                attempts += 1
                return attempts
            }
            let (stream, continuation) = AsyncThrowingStream.makeStream(of: HealthResult.self)
            continuation.yield(HealthResult(workouts: attempt == 1 ? [cachedWorkout] : [], unit: .miles, cached: true))
            if attempt < 3 {
                continuation.finish(throwing: CocoaError(.fileReadUnknown))
            } else {
                continuation.yield(HealthResult(workouts: [], unit: .miles, cached: false))
                continuation.finish()
            }
            return stream
        }
    }
}

private final class SuspendedHealthProvider: HealthProvider {
    private let onStart: @Sendable () -> Void
    private let updates = AsyncThrowingStream.makeStream(of: HealthResult.self)

    init(onStart: @escaping @Sendable () -> Void) {
        self.onStart = onStart
    }

    func details(for workout: Workout) async throws -> WorkoutDetails { WorkoutDetails() }

    func workoutUpdates() -> AsyncThrowingStream<HealthResult, Error> {
        onStart()
        return updates.stream
    }

    func complete(with workout: Workout) {
        updates.continuation.yield(HealthResult(workouts: [workout], unit: .miles, cached: false))
    }
}
