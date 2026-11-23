import HealthKit
import XCTest
@testable import BikeLog

final class WorkoutCacheTests: XCTestCase {
    @MainActor
    func testMigrationMovesOnlyLegacyCacheAndNextSaveReplacesIt() async throws {
        let root = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        let documents = root.appending(path: "Documents")
        let directory = root.appending(path: "Cache")
        try FileManager.default.createDirectory(at: documents, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let legacy = documents.appending(path: "cycling")
        let unrelated = documents.appending(path: "notes.txt")
        let oldWorkout = makeWorkout()
        let original = HealthResult(workouts: [oldWorkout], unit: .miles, cached: true,
                                    anchor: HKQueryAnchor(fromValue: 1))
        try JSONEncoder().encode(original).write(to: legacy)
        try Data("leave this alone".utf8).write(to: unrelated)

        let cache = WorkoutCache(directory: directory, legacyDirectory: documents)
        let migrated = try await cache.load()
        XCTAssertEqual(migrated?.workouts, [oldWorkout])
        XCTAssertNotNil(migrated?.anchor)
        XCTAssertFalse(FileManager.default.fileExists(atPath: legacy.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: unrelated.path))

        let newWorkout = makeWorkout()
        try await cache.save(original.applying(added: [newWorkout], deleted: [oldWorkout.id],
                                               newAnchor: HKQueryAnchor(fromValue: 2)))
        let latest = try await cache.load()
        XCTAssertEqual(latest?.workouts, [newWorkout])
        XCTAssertEqual(latest?.cached, true)
        XCTAssertNotNil(latest?.anchor)
    }

    func testUnreadableAnchorRebuildsSnapshotThenAppliesDeltas() throws {
        let stale = makeWorkout()
        let original = HealthResult(workouts: [stale], unit: .miles, cached: true,
                                    anchor: HKQueryAnchor(fromValue: 1))
        let encoded = try JSONEncoder().encode(original)
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        json["anchor"] = 42
        let decoded = try JSONDecoder().decode(HealthResult.self, from: JSONSerialization.data(withJSONObject: json))
        XCTAssertNil(decoded.anchor)
        XCTAssertEqual(decoded.workouts, [stale])

        let first = makeWorkout()
        let restored = decoded.applying(added: [first], deleted: [], newAnchor: HKQueryAnchor(fromValue: 2))
        XCTAssertEqual(restored.workouts, [first])

        let second = makeWorkout()
        let third = makeWorkout()
        let updated = restored.applying(added: [second, third, third], deleted: [first.id],
                                        newAnchor: HKQueryAnchor(fromValue: 3))
        let final = updated.applying(added: [first], deleted: [second.id], newAnchor: HKQueryAnchor(fromValue: 4))
        XCTAssertEqual(Set(final.workouts), [first, third])
        XCTAssertEqual(final.workouts.count, 2)
    }

    private func makeWorkout() -> Workout {
        Workout(id: UUID(), startDate: .distantPast, endDate: .distantPast,
                duration: 600, distance: Measurement(value: 2, unit: .miles))
    }
}
