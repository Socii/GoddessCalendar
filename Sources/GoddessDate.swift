// Goddess Calendar

import Foundation

// MARK: - Definition

public struct GoddessDate {
  
  public let cycle: Int
  
  public let year: GoddessCalendar.Year
  
  public let month: GoddessCalendar.Month
  
  public let day: Int
  
  /// Create a new Goddess date component,
  /// or `nil` if the date components do not
  /// represent a day in the calendar.
  /// - Parameters:
  ///   - cycle: The cycle number.
  ///   - year: The year number.
  ///   - month: The month number.
  ///   - day: The day number.
  public init?(cycle: Int = 1, year: Int, month ordinalMonth: Int, day: Int) {
    
    // Cycle.
    self.cycle = cycle
    
    // Year.
    guard GoddessCalendar.Cycle.years ~= year else {
      logln("Year \(year) does not exist in the calendar.", level: .error)
      return nil
    }
    self.year = GoddessCalendar.Year(year)
    
    // Month.
    guard GoddessCalendar.Year.months ~= ordinalMonth else {
      logln("Month \(ordinalMonth) does not exist in the calendar.", level: .error)
      return nil
    }
    self.month = GoddessCalendar.Month(ordinal: ordinalMonth, length: self.year.length)

    // Day.
    guard 1...self.month.days ~= day else {
      logln("Day \(day) does not exist in the month.", level: .error)
      return nil
    }
    self.day = day
  }
  
  /// Create a new Goddess date component from a `Date`.
  /// - Parameters:
  ///   - from: The date object.
  public init(from date: Date) {
    
    // Offset the date using the goddess calendar start date,
    // using the time interval since 1970 as a reference point.
    let offset = date.timeIntervalSince1970 - GoddessCalendar.zeroDate.timeIntervalSince1970
    
    // Cycle.
    var cycle = Int(offset) / Int(Cycle.seconds) + 1
    
    // Year.
    var yearSeconds = 0.0
    if cycle > 1 {
      yearSeconds = offset.remainder(dividingBy: Cycle.seconds)
    } else {
      yearSeconds = offset
    }
    let secondsPerYear = Cycle.accumulatedSecondsPerYear.filter { $0 <= yearSeconds }
    //    debug.append("Seconds Per Year: \(secondsPerYear)\n")
    var year = Year(secondsPerYear.count + 1)
    
    // Month.
    let monthSeconds = yearSeconds - (secondsPerYear.last ?? 0.0)
    let secondsPerMonth = Month.accumulatedSeconds(for: year.length).filter { $0 <= monthSeconds }
    var monthOrdinal = secondsPerMonth.count + 1
    var month = Month(ordinal: monthOrdinal, length: year.length)
    
    // Day.
    let daySeconds = monthSeconds - (secondsPerMonth.last ?? 0.0)
    var day = Int(daySeconds) / Int(Day.seconds) + 1
    
    // Overflow adjustments.
    if day > month.days {
      var yearOrdinal = year.ordinal
      day -= month.days
      monthOrdinal += 1
      if monthOrdinal > Year.months.count {
        monthOrdinal = 1
        yearOrdinal += 1
        if yearOrdinal > Cycle.years.count {
          yearOrdinal = 1
          cycle += 1
        }
        year = Year(yearOrdinal)
      }
      month = Month(ordinal: monthOrdinal, length: year.length)
    }
    
    self.cycle = cycle
    self.year = year
    self.month = month
    self.day = day
  }
}

// MARK: - Calculated Properties

public extension GoddessDate {
  
  /// Returns the date represented by these components.
  ///
  /// - Remark: Returns `nil` if the components don't
  ///   represent a valid date in the Goddess calendar.
  var date: Date {
    
    // Convert the components to a time interval.
    var interval: TimeInterval = 0.0
    
    // Add the number of cycle's in seconds.
    interval += Cycle.seconds * Double(cycle - 1)
    
    // Add the number of years in seconds.
    // FIXME: No need to filter arrays again, already done in cycle.
    let previousNormalYears = Cycle.years(for: .normal).filter { $0 < year.ordinal }
    let previousShortYears = Cycle.years(for: .short).filter { $0 < year.ordinal }
    interval += (TimeInterval(previousNormalYears.count) * Year.Length.normal.seconds) + (TimeInterval(previousShortYears.count) * Year.Length.short.seconds)
    
    // Add the number of days in the previous
    // months, converted to seconds.
    let length = Year.length(for: year.ordinal)
    let accumulatedDays = Year.accumulatedDays(for: length)[0..<month.ordinal - 1]
    interval += TimeInterval(accumulatedDays.last ?? 0) * Day.seconds
    
    // Add the previous number of days, converted to seconds.
    interval += TimeInterval(day - 1) * Day.seconds
    
    // Calculate the date, offset from the calendar
    // start date, using the created time interval.
    let timeInterval = TimeInterval(interval) + GoddessCalendar.zeroDate.timeIntervalSince1970
    return Date(timeIntervalSince1970: timeInterval)
  }
  
  var dayInYear: Int {
    return day + Year.dayCount(to: month, for: year.length)
  }
}


// MARK: - Equatable

extension GoddessDate: Equatable {
  public static func == (lhs: GoddessDate, rhs: GoddessDate) -> Bool {
    return lhs.cycle == rhs.cycle &&
      lhs.year.ordinal == rhs.year.ordinal &&
      lhs.month.ordinal == rhs.month.ordinal &&
      lhs.day == rhs.day
  }
}


// MARK: - Custom String Convertible

extension GoddessDate: CustomStringConvertible {
  public var description: String {
    return "\(cycle)-\(year.ordinal)-\(month.ordinal)-\(day) \(GoddessCalendar.timeZone)"
  }
}

// MARK: - Formatted String

public extension GoddessDate {
  
  /// Returns the Goddess date as a short string,
  /// such as `"113-3-17"`
  var shortString: String {
    return "\(year.ordinal)-\(month.ordinal)-\(day)"
  }
  
  /// Returns the Goddess date as a medium string,
  /// such as `"113-Epona-17"`
  var mediumString: String {
    return "\(year.ordinal)-\(month.name)-\(day)"
  }
  
  /// Returns the Goddess date as a full string,
  /// such as `"113-Epona-17 MMG"`
  var fullString: String {
    return "\(cycle)-\(year.ordinal)-\(month.name)-\(day) \(GoddessCalendar.timeZone)"
  }
}
