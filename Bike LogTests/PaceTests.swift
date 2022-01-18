//
//  PaceTests.swift
//  Bike LogTests
//
//  Created by Ameir Al-Zoubi on 1/17/22.
//

import XCTest
@testable import Bike_Log

class PaceTests: XCTestCase {
    func testPaceMiles1() {
        let distance = Measurement(value: 2, unit: UnitLength.miles)
        let duration = Measurement(value: 20, unit: UnitDuration.minutes)
        let speed = (distance / duration).converted(to: .minutesPerMile)
        XCTAssertEqual(speed.value, 10, accuracy: 0.00001)
    }
    
    func testPaceMiles2() {
        let distance = Measurement(value: 2, unit: UnitLength.miles)
        let duration = Measurement(value: 20.5, unit: UnitDuration.minutes)
        let speed = (distance / duration).converted(to: .minutesPerMile)
        XCTAssertEqual(speed.value, 10.25, accuracy: 0.00001)
    }
    
    func testPaceMiles3() {
        let distance = Measurement(value: 2, unit: UnitLength.miles)
        let duration = Measurement(value: 17.4166, unit: UnitDuration.minutes)
        let speed = (distance / duration).converted(to: .minutesPerMile)
        XCTAssertEqual(speed.value, 8.7083, accuracy: 0.00001)
    }
    
    func testPaceKM1() {
        let distance = Measurement(value: 2, unit: UnitLength.kilometers)
        let duration = Measurement(value: 20, unit: UnitDuration.minutes)
        let speed = (distance / duration).converted(to: .minutesPerKilometer)
        XCTAssertEqual(speed.value, 10, accuracy: 0.00001)
    }
    
    func testPaceKM2() {
        let distance = Measurement(value: 2, unit: UnitLength.kilometers)
        let duration = Measurement(value: 20.5, unit: UnitDuration.minutes)
        let speed = (distance / duration).converted(to: .minutesPerKilometer)
        XCTAssertEqual(speed.value, 10.25, accuracy: 0.00001)
    }
    
    func testPaceKM3() {
        let distance = Measurement(value: 2, unit: UnitLength.kilometers)
        let duration = Measurement(value: 17.4166, unit: UnitDuration.minutes)
        let speed = (distance / duration).converted(to: .minutesPerKilometer)
        XCTAssertEqual(speed.value, 8.7083, accuracy: 0.00001)
    }

    func testFormattedPace1() {
        let pace: TimeInterval = (11 * 60) + 8
        let duration: TimeInterval = pace * 3
        let distance = Measurement(value: 3, unit: UnitLength.miles)
        let workout = Workout(id: UUID(), startDate: Date(), endDate: Date() + duration, type: .running, duration: duration, distance: distance, unit: .miles)
        XCTAssertEqual(WorkoutViewModel(workout: workout).formattedSpeed, "11'8\"/mi")
    }
    
    func testFormattedPace2() {
        let duration: TimeInterval = (47 * 60) + 46
        let distance = Measurement(value: 5, unit: UnitLength.miles)
        let workout = Workout(id: UUID(), startDate: Date(), endDate: Date() + duration, type: .running, duration: duration, distance: distance, unit: .miles)
        XCTAssertEqual(WorkoutViewModel(workout: workout).formattedSpeed, "9'33\"/mi")
    }
}
