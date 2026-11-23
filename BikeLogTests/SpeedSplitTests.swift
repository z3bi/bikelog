import XCTest
@testable import BikeLog

final class SpeedSplitTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_000)

    func testCompletedMilesIncludeStopsAndInterpolateCrossings() {
        let splits = calculate([
            sample(130, 190, 0.75, .miles),
            sample(0, 90, 0.75, .miles),
            sample(190, 250, 0.75, .miles)
        ], in: .miles, end: 250)

        XCTAssertEqual(splits.map(\.index), [1, 2])
        guard splits.count == 2 else { return }
        XCTAssertEqual(splits[0].elapsed, 150, accuracy: 0.001)
        XCTAssertEqual(splits[1].elapsed, 80, accuracy: 0.001)
        XCTAssertEqual(splits[0].speed(in: .milesPerHour).value, 24, accuracy: 0.001)
        XCTAssertEqual(splits[1].speed(in: .milesPerHour).value, 45, accuracy: 0.001)
    }

    func testMetricUnitSplitsByKilometer() {
        let splits = calculate([
            sample(0, 90, 0.75, .kilometers),
            sample(130, 190, 0.75, .kilometers),
            sample(190, 250, 0.75, .kilometers)
        ], in: .kilometers, end: 250)

        XCTAssertEqual(splits.map(\.index), [1, 2])
        guard splits.count == 2 else { return }
        XCTAssertEqual(splits[0].speed(in: .kilometersPerHour).value, 24, accuracy: 0.001)
        XCTAssertEqual(splits[1].speed(in: .kilometersPerHour).value, 45, accuracy: 0.001)
    }

    func testNoChartForPartialSplitOrAggregateDistance() {
        XCTAssertTrue(calculate([
            sample(0, 60, 0.25, .miles), sample(60, 120, 0.5, .miles)
        ], in: .miles, end: 120).isEmpty)

        XCTAssertTrue(calculate([sample(0, 120, 2, .miles)], in: .miles, end: 120).isEmpty)
    }

    func testOverlappingDistancesAreNotCountedTwice() {
        XCTAssertTrue(calculate([
            sample(0, 60, 0.75, .miles), sample(30, 90, 0.75, .miles)
        ], in: .miles, end: 90).isEmpty)
    }

    private func calculate(_ samples: [SpeedSplit.DistanceSample], in unit: UnitLength, end: TimeInterval) -> [SpeedSplit] {
        SpeedSplit.calculate(samples: samples, splitLength: unit.splitLength, workoutStart: start, workoutEnd: start + end)
    }

    private func sample(_ begin: TimeInterval, _ end: TimeInterval, _ distance: Double,
                        _ unit: UnitLength) -> SpeedSplit.DistanceSample {
        .init(start: start + begin, end: start + end,
              meters: Measurement(value: distance, unit: unit).converted(to: .meters).value)
    }
}
