//
//  DatePeriodTests.swift
//  Bike LogTests
//
//  Created by Ameir Al-Zoubi on 1/17/22.
//

import XCTest
@testable import BikeLog

class DatePeriodTests: XCTestCase {

    let cal = Calendar(identifier: .gregorian)
    
    func testAllPeriod() {
        let testDate = Date()
        let interval = StatisticalPeriod.all.dateInterval(from: testDate)
        XCTAssertEqual(interval.start, Date.distantPast)
        XCTAssertEqual(interval.end, Date.distantFuture)
    }
    
    func testYearPeriod() {
        let testDate = cal.date(from: DateComponents(year: 2020, month: 6, day: 16))!
        let interval = StatisticalPeriod.year.dateInterval(from: testDate)
        
        let start = cal.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let end = cal.date(from: DateComponents(year: 2021, month: 1, day: 1))!
        XCTAssertEqual(interval.start, start)
        XCTAssertEqual(interval.end, end)
    }
    
    func testMonthPeriod() {
        let testDate = cal.date(from: DateComponents(year: 2020, month: 6, day: 16))!
        let interval = StatisticalPeriod.month.dateInterval(from: testDate)
        
        let start = cal.date(from: DateComponents(year: 2020, month: 6, day: 1))!
        let end = cal.date(from: DateComponents(year: 2020, month: 7, day: 1))!
        XCTAssertEqual(interval.start, start)
        XCTAssertEqual(interval.end, end)
    }
    
    func testWeekPeriod1() {
        let testDate = cal.date(from: DateComponents(year: 2022, month: 1, day: 20))!
        let interval = StatisticalPeriod.week.dateInterval(from: testDate)
        
        let start = cal.date(from: DateComponents(year: 2022, month: 1, day: 17))!
        let end = cal.date(from: DateComponents(year: 2022, month: 1, day: 24))!
        XCTAssertEqual(interval.start, start)
        XCTAssertEqual(interval.end, end)
        
        let sundayNight = cal.date(from: DateComponents(year: 2022, month: 1, day: 23, hour: 23, minute: 59, second: 59))!
        XCTAssertTrue(interval.contains(sundayNight))
        
        let mondayMorning = cal.date(from: DateComponents(year: 2022, month: 1, day: 24, hour: 1, minute: 1, second: 1))!
        XCTAssertFalse(interval.contains(mondayMorning))
    }

    func testWeekPeriod2() {
        let testDate = cal.date(from: DateComponents(year: 2022, month: 1, day: 17, hour: 23, minute: 59, second: 59))!
        let interval = StatisticalPeriod.week.dateInterval(from: testDate)
        
        let start = cal.date(from: DateComponents(year: 2022, month: 1, day: 17))!
        let end = cal.date(from: DateComponents(year: 2022, month: 1, day: 24))!
        XCTAssertEqual(interval.start, start)
        XCTAssertEqual(interval.end, end)
        
        let sundayNight = cal.date(from: DateComponents(year: 2022, month: 1, day: 23, hour: 23, minute: 59, second: 59))!
        XCTAssertTrue(interval.contains(sundayNight))
        
        let mondayMorning = cal.date(from: DateComponents(year: 2022, month: 1, day: 24, hour: 1, minute: 1, second: 1))!
        XCTAssertFalse(interval.contains(mondayMorning))
    }

    func testYearlyTotalsUseLocalYearBoundariesAndConvertDistancesToMiles() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "America/Los_Angeles"))
        let workouts = try [
            ride(start: "2023-01-01T07:59:00Z", distance: Measurement(value: 10, unit: .miles)),
            ride(start: "2023-01-01T08:00:00Z", distance: Measurement(value: 16.09344, unit: .kilometers)),
            ride(start: "2023-06-01T00:00:00Z", distance: Measurement(value: 5, unit: .miles)),
            ride(start: "2020-06-01T00:00:00Z", distance: Measurement(value: 20, unit: .miles)),
        ]

        let totals = WorkoutPeriodTotal.yearly(workouts, calendar: calendar)

        XCTAssertEqual(totals.map { calendar.component(.year, from: $0.startDate) }, [2023, 2022, 2020])
        XCTAssertEqual(totals.map(\.count), [2, 1, 1])
        XCTAssertEqual(try XCTUnwrap(totals.first).miles, 15, accuracy: 0.001)
    }

    func testYearlyTotalsAreEmptyWhenThereAreNoWorkouts() {
        XCTAssertTrue(WorkoutPeriodTotal.yearly([], calendar: cal).isEmpty)
    }

    func testMonthlyTotalsIncludeOnlyMonthsWithWorkoutsInSelectedLocalYear() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "America/Los_Angeles"))
        let year = try Date("2023-01-01T08:00:00Z", strategy: .iso8601)
        let workouts = try [
            ride(start: "2023-01-01T07:59:59Z", distance: Measurement(value: 7, unit: .miles)),
            ride(start: "2023-01-01T08:00:00Z", distance: Measurement(value: 5, unit: .miles)),
            ride(start: "2024-01-01T07:59:59Z", distance: Measurement(value: 10, unit: .miles)),
            ride(start: "2023-12-17T20:00:00Z", distance: Measurement(value: 8.04672, unit: .kilometers)),
            ride(start: "2024-01-01T08:00:00Z", distance: Measurement(value: 8, unit: .miles)),
        ]

        let totals = WorkoutPeriodTotal.monthly(workouts, in: year, calendar: calendar)

        XCTAssertEqual(totals.map { calendar.component(.month, from: $0.startDate) }, [12, 1])
        XCTAssertEqual(totals.map(\.count), [2, 1])
        XCTAssertEqual(try XCTUnwrap(totals.first).miles, 15, accuracy: 0.001)
        XCTAssertEqual(totals.last?.miles, 5)
    }

    func testWorkoutListFiltersToSelectedLocalMonthAndKeepsInputOrder() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "America/Los_Angeles"))
        let month = try Date("2024-03-01T08:00:00Z", strategy: .iso8601)
        let distance = Measurement(value: 5, unit: UnitLength.miles)
        let first = try ride(start: "2024-03-01T08:00:00Z", distance: distance)
        let last = try ride(start: "2024-04-01T06:59:59Z", distance: distance)
        let outside = try [
            ride(start: "2024-03-01T07:59:59Z", distance: distance),
            ride(start: "2024-04-01T07:00:00Z", distance: distance),
            ride(start: "2023-03-01T08:00:00Z", distance: distance),
        ]
        let workouts = [last] + outside + [first]

        let interval = StatisticalPeriod.month.dateInterval(from: month, calendar: calendar)
        XCTAssertEqual(WorkoutPeriodTotal.workouts(workouts, in: interval), [last, first])
    }

    func testWeekSummaryAndWorkoutListAgreeAtMondayBoundariesAcrossDaylightSaving() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "America/Los_Angeles"))
        calendar.firstWeekday = 1
        let sunday = try Date("2024-03-10T18:00:00Z", strategy: .iso8601)
        let distance = Measurement(value: 5, unit: UnitLength.miles)
        let first = try ride(start: "2024-03-04T08:00:00Z", distance: distance)
        let last = try ride(start: "2024-03-11T06:59:59Z", distance: distance)
        let previous = try ride(start: "2024-03-04T07:59:59Z", distance: distance)
        let next = try ride(start: "2024-03-11T07:00:00Z", distance: distance)
        let workouts = [next, last, first, previous]
        let summary = StatsViewModel(date: sunday, period: .week, activity: .cycling,
                                     unit: .miles, workouts: workouts, calendar: calendar)

        XCTAssertEqual(summary.workouts, [last, first])
        XCTAssertEqual(WorkoutPeriodTotal.workouts(workouts, in: summary.dateInterval), [last, first])
    }

    func testHeaderDistanceUsesPreferredUnitForMixedWorkoutUnits() throws {
        let date = "2024-03-11T12:00:00Z"
        let workouts = try [
            ride(start: date, distance: Measurement(value: 1, unit: .miles)),
            ride(start: date, distance: Measurement(value: 2, unit: .kilometers)),
        ]
        let summary = StatsViewModel(date: try Date(date, strategy: .iso8601), period: .all,
                                     activity: .cycling, unit: .kilometers, workouts: workouts)
        let expected = Measurement(value: 3.609344, unit: UnitLength.kilometers)
            .formatted(LengthFormat.lengthFormat(fractions: 1))

        XCTAssertEqual(summary.totalDistance(), expected)
    }

    private func ride(start: String, distance: Measurement<UnitLength>) throws -> Workout {
        let startDate = try Date(start, strategy: .iso8601)
        return Workout(id: UUID(),
                       startDate: startDate,
                       endDate: startDate.addingTimeInterval(600),
                       activity: .cycling,
                       duration: 600,
                       distance: distance)
    }
}
