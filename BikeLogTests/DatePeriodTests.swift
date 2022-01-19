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
}
