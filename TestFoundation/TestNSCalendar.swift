// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

#if DEPLOYMENT_RUNTIME_OBJC || os(Linux)
import Foundation
import XCTest
#else
import SwiftFoundation
import SwiftXCTest
#endif
import CoreFoundation

class TestNSCalendar: XCTestCase {
    
    static var allTests: [(String, (TestNSCalendar) -> () throws -> Void)] {
        return [
            ("test_allCalendars", test_allCalendars),
            ("test_gettingDatesOnGregorianCalendar", test_gettingDatesOnGregorianCalendar ),
            ("test_gettingDatesOnHebrewCalendar", test_gettingDatesOnHebrewCalendar ),
            ("test_gettingDatesOnChineseCalendar", test_gettingDatesOnChineseCalendar),
            ("test_gettingDatesOnISO8601Calendar", test_gettingDatesOnISO8601Calendar),
            ("test_copy",test_copy),
            ("test_addingDates", test_addingDates)
            // Disabled because this fails on linux https://bugs.swift.org/browse/SR-320
            // ("test_currentCalendarRRstability", test_currentCalendarRRstability),
        ]
    }
    
    func test_allCalendars() {
        for identifier in [
            Calendar.Identifier.buddhist,
            Calendar.Identifier.chinese,
            Calendar.Identifier.coptic,
            Calendar.Identifier.ethiopicAmeteAlem,
            Calendar.Identifier.ethiopicAmeteMihret,
            Calendar.Identifier.gregorian,
            Calendar.Identifier.hebrew,
            Calendar.Identifier.indian,
            Calendar.Identifier.islamic,
            Calendar.Identifier.islamicCivil,
            Calendar.Identifier.islamicTabular,
            Calendar.Identifier.islamicUmmAlQura,
            Calendar.Identifier.iso8601,
            Calendar.Identifier.japanese,
            Calendar.Identifier.persian,
            Calendar.Identifier.republicOfChina
            ] {
                let calendar = Calendar(identifier: identifier)
                XCTAssertEqual(identifier,calendar.identifier)
        }
    }

    func test_gettingDatesOnGregorianCalendar() {
        let date = Date(timeIntervalSince1970: 1449332351)
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
         let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        XCTAssertEqual(components.year, 2015)
        XCTAssertEqual(components.month, 12)
        XCTAssertEqual(components.day, 5)
    }

    func test_gettingDatesOnISO8601Calendar() {
        let date = Date(timeIntervalSince1970: 1449332351)

        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        XCTAssertEqual(components.year, 2015)
        XCTAssertEqual(components.month, 12)
        XCTAssertEqual(components.day, 5)
    }

    
    func test_gettingDatesOnHebrewCalendar() {
        let date = Date(timeIntervalSince1970: 1552580351)
        
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        XCTAssertEqual(components.year, 5779)
        XCTAssertEqual(components.month, 7)
        XCTAssertEqual(components.day, 7)
        XCTAssertEqual(components.isLeapMonth, false)
    }
    
    func test_gettingDatesOnChineseCalendar() {
        let date = Date(timeIntervalSince1970: 1591460351.0)
        
        var calendar = Calendar(identifier: .chinese)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        XCTAssertEqual(components.year, 37)
        XCTAssertEqual(components.month, 4)
        XCTAssertEqual(components.day, 15)
        XCTAssertEqual(components.isLeapMonth, true)
    }

    func test_currentRRstability() {
        var AMSymbols = [String]()
        for _ in 1...10 {
            let cal = Calendar.current
            AMSymbols.append(cal.amSymbol)
        }
        
        XCTAssertEqual(AMSymbols.count, 10, "Accessing current calendar should work over multiple callouts")
    }
    
    func test_copy() {
        var calendar = Calendar.current

        //Mutate below fields and check if change is being reflected in copy.
        calendar.firstWeekday = 2 
        calendar.minimumDaysInFirstWeek = 2

        let copy = calendar
        XCTAssertTrue(copy == calendar)

        //verify firstWeekday and minimumDaysInFirstWeek of 'copy'. 
        XCTAssertEqual(copy.firstWeekday, 2)
        XCTAssertEqual(copy.minimumDaysInFirstWeek, 2)
    }
    
    func test_addingDates() {
        let calendar = Calendar(identifier: .gregorian)
        let thisDay = calendar.date(from: DateComponents(year: 2016, month: 10, day: 4))!
        let diffComponents = DateComponents(day: 1)
        let dayAfter = calendar.date(byAdding: diffComponents, to: thisDay)
        
        let dayAfterComponents = calendar.dateComponents([.year, .month, .day], from: dayAfter!)
        XCTAssertEqual(dayAfterComponents.year, 2016)
        XCTAssertEqual(dayAfterComponents.month, 10)
        XCTAssertEqual(dayAfterComponents.day, 5)
    }
}

class TestNSDateComponents: XCTestCase {

    static var allTests: [(String, (TestNSDateComponents) -> () throws -> Void)] {
        return [
            ("test_copyNSDateComponents", test_copyNSDateComponents),
        ]
    }

    func test_copyNSDateComponents() {
        let components = NSDateComponents()
        components.year = 1987
        components.month = 3
        components.day = 17
        components.hour = 14
        components.minute = 20
        components.second = 0
        let copy = components.copy(with: nil) as! NSDateComponents
        XCTAssertTrue(components.isEqual(copy))
        XCTAssertTrue(components == copy)
        XCTAssertFalse(components === copy)
        XCTAssertEqual(copy.year, 1987)
        XCTAssertEqual(copy.month, 3)
        XCTAssertEqual(copy.day, 17)
        XCTAssertEqual(copy.isLeapMonth, false)
        //Mutate NSDateComponents and verify that it does not reflect in the copy
        components.hour = 12
        XCTAssertEqual(components.hour, 12)
        XCTAssertEqual(copy.hour, 14)
    }
}
