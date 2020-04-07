// GoddessCalendarTests

import XCTest
@testable import GoddessCalendar

class GoddessCalendarTests: XCTestCase {
  
  override func setUp() {
    //    logln("\n\(String(describing: goddessCalendar))", level: .passed)
  }
  
  override func tearDown() {
    
  }
}

extension GoddessCalendarTests {
  
   func testGoddessCalendar() {
   
   // Cycle
   XCTAssertEqual(GoddessCalendar.Cycle.years.count, 470)
   XCTAssertEqual(GoddessCalendar.Cycle.years(for: .normal).count, 422)
   XCTAssertEqual(GoddessCalendar.Cycle.years(for: .short).count, 48)
//   XCTAssertEqual(GoddessCalendar.Cycle.months.count, 6110)
   XCTAssertEqual(GoddessCalendar.Cycle.days, 180432)
   XCTAssertEqual(GoddessCalendar.Cycle.seconds, 15589324800)
   
   XCTAssertEqual(GoddessCalendar.Year.days(for: .normal), 384)
   XCTAssertEqual(GoddessCalendar.Year.days(for: .short), 383)
   XCTAssertEqual(GoddessCalendar.Year.seconds(for: .normal), 33177600)
   XCTAssertEqual(GoddessCalendar.Year.seconds(for: .short), 33091200)
   
   XCTAssertEqual(GoddessCalendar.Year.months.count, 13)
   
   
   
   /// Test the start date against 14-08-1901 in the gregorian calendar.
   let calendar = Calendar(identifier: .gregorian)
   let components = DateComponents(calendar: calendar, year: 1901, month: 8, day: 14)
   guard let syncDate = calendar.date(from: components) else { fatalError() }
   XCTAssertEqual(GoddessCalendar.zeroDate, syncDate)
   }

  
  func testABunchOfDates() {
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    let dates = [(formatter.date(from: "1901-08-14"), (1, 1, 1, 1)),
                 (formatter.date(from: "2019-05-04"), (1, 113, 1, 1)),
                 (formatter.date(from: "2019-07-25"), (1, 113, 3, 24)),
                 (formatter.date(from: "2020-05-21"), (1, 113, 13, 30)),
                 (formatter.date(from: "2147-07-28"), (1, 235, 1, 1)),
                 (formatter.date(from: "2148-08-13"), (1, 235, 13, 29)),
                 (formatter.date(from: "2148-04-25"), (1, 235, 10, 7)),
                 (formatter.date(from: "2394-07-29"), (1, 470, 1, 1)),
                 (formatter.date(from: "2395-08-15"), (1, 470, 13, 29)),
                 (formatter.date(from: "2279-05-26"), (1, 360, 6, 15))]
    
    /// Test component to date conversion.
    for (date, goddess) in dates {
      let components = GoddessDate(cycle: goddess.0,
                                   year: goddess.1,
                                   month: goddess.2,
                                   day: goddess.3)
      /// Check components from date.
      XCTAssertNotNil(components)
      
      /// Check date from components.
      let goddessDate = components!.date
//      logln("\n        Date: \(String(describing: date))\nGoddess Date: \(String(describing: goddessDate))", level: .none)
      XCTAssert(date == goddessDate)
      
      /// Check components from date.
      let newComponents = GoddessDate(from: date!)
//      logln("\n\(String(describing: components))\n\(String(describing: newComponents))")
      XCTAssert(newComponents == components)
    }
  }
}
