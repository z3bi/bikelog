import XCTest
@testable import BikeLog

final class MileSpeedSplitTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_000)

    func testCompletedMilesIncludeStopsAndInterpolateCrossings() {
        let splits = MileSpeedSplit.calculate(samples: [
            sample(130, 190, miles: 0.75),
            sample(0, 90, miles: 0.75),
            sample(190, 250, miles: 0.75)
        ], workoutStart: start, workoutEnd: start + 250)

        XCTAssertEqual(splits.map(\.mile), [1, 2])
        guard splits.count == 2 else { return }
        XCTAssertEqual(splits[0].elapsed, 150, accuracy: 0.001)
        XCTAssertEqual(splits[1].elapsed, 80, accuracy: 0.001)
        XCTAssertEqual(splits[0].milesPerHour, 24, accuracy: 0.001)
        XCTAssertEqual(splits[1].milesPerHour, 45, accuracy: 0.001)
    }

    func testNoChartForPartialMileOrAggregateDistance() {
        XCTAssertTrue(MileSpeedSplit.calculate(samples: [
            sample(0, 60, miles: 0.25), sample(60, 120, miles: 0.5)
        ], workoutStart: start, workoutEnd: start + 120).isEmpty)

        XCTAssertTrue(MileSpeedSplit.calculate(samples: [
            sample(0, 120, miles: 2)
        ], workoutStart: start, workoutEnd: start + 120).isEmpty)
    }

    func testOverlappingDistancesAreNotCountedTwice() {
        XCTAssertTrue(MileSpeedSplit.calculate(samples: [
            sample(0, 60, miles: 0.75), sample(30, 90, miles: 0.75)
        ], workoutStart: start, workoutEnd: start + 90).isEmpty)
    }

    private func sample(_ begin: TimeInterval, _ end: TimeInterval, miles: Double) -> MileSpeedSplit.DistanceSample {
        .init(start: start + begin, end: start + end, meters: miles * MileSpeedSplit.metersPerMile)
    }
}
