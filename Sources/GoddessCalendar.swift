// Goddess Calendar

import Foundation

// Typealiases for use within the framework.
typealias Cycle = GoddessCalendar.Cycle
typealias Year = GoddessCalendar.Year
typealias Month = GoddessCalendar.Month
typealias Day = GoddessCalendar.Day

// MARK: Definition

/// A model of the McKenna-Meyer Goddess Calendar;
/// an accurate 13-month lunar calendar in which
/// the months coincide with the lunar cycle.
///
/// Originally designed by Terence McKenna and Peter Meyer.
///
/// For more information, see
/// [www.fractal-timewave.com](http://www.fractal-timewave.com)
public enum GoddessCalendar {
  
  /// The zero date of the Goddess calendar.
  ///
  /// Defined as:
  ///
  /// **14, Aug, 1901 - 00:00:00 UTC**
  ///
  /// in the gregorian calendar.
  static let zeroDate: Date = {
    let gregorian = Calendar(identifier: .gregorian)
    guard let utc = TimeZone(identifier: "UTC") else {
      preconditionFailure("Unable to create UTC timezone.")
    }
    let components = DateComponents(calendar: gregorian, timeZone: utc, year: 1901, month: 8, day: 14)
    guard let date = gregorian.date(from: components) else {
      preconditionFailure("Unable to create date from components.")
    }
    return date
  }()
}

// MARK: - Cycle

extension GoddessCalendar {

  public enum Cycle {
    
    static let years = 1...470
    
    /// Returns an Integer Array containing the year numbers
    /// of every year in a cycle.
    static func years(for length: Year.Length) -> [Int] {
      
      // Cached results.
      switch length {
      case .normal:
        return { years.filter() { Year.length(for: $0) == .normal } }()
      case .short:
        return { years.filter() { Year.length(for: $0) == .short } }()
      }
    }
    
    /// The number of months in a cycle.
//    static let months = Month.all.count * Cycle.years.count
    
    /// The number of days in a cycle.
    static let days = (years(for: .normal).count * Year.days(for: .normal)) + (years(for: .short).count * Year.days(for: .short))
    
    /// The number of seconds in a cycle.
    static let seconds: TimeInterval = (Year.seconds(for: .normal) * TimeInterval(years(for: .normal).count))
      + (Year.seconds(for: .short) * TimeInterval(years(for: .short).count))
    
    /// The number of accumulated seconds
    /// for each year in a cycle.
    static let accumulatedSecondsPerYear: [TimeInterval] = {
      var seconds = [TimeInterval]()
      var total = 0.0
      for year in years {
        let length = Year.length(for: year)
        total += Year.seconds(for: length)
        seconds.append(total)
      }
      return seconds
    }()
  }
}

// MARK: - Year

extension GoddessCalendar{
  
  public struct Year {
    
    public enum Length {
      
      case normal
      case short
      
      var days: Int {
        switch self {
        case .normal: return Year.days(for: .normal)
        case .short: return Year.days(for: .short)
        }
      }
      
      var seconds: TimeInterval {
        switch self {
        case .normal: return Year.seconds(for: .normal)
        case .short: return Year.seconds(for: .short)
        }
      }
    }
    
    public let ordinal: Int
    
    public let length: Length
    
    init(_ ordinal: Int) {
      guard Cycle.years ~= ordinal else {
        preconditionFailure("Year \(ordinal) does not exist in the calendar.")
      }
      self.ordinal = ordinal
      self.length = Year.length(for: ordinal)
    }
    
    /// The length of a given year.
    static func length(for year: Int) -> Year.Length {
      return year % 10 == 0 || year % 235 == 0 ? .short : .normal
    }
    
    /// The ordinal numbers for each month in the year.
    static let months = 1...13
    
    static func months(for length: Year.Length) -> [Month] {
      var array = [Month]()
      for month in months {
        array.append(Month(ordinal: month, length: length))
      }
      return array
    }
    
    // FIXME:
    /// The number of days in a year.
    static func days(for length: Year.Length) -> Int {
      
      // Cached results.
      switch length {
      case .normal: return {
        var days = 0
        for month in months(for: .normal) {
          days += month.days
        }
        return days
        }()
    
      case .short: return {
        var days = 0
        for month in months(for: .short) {
          days += month.days
        }
        return days
        }()
      }
    }
    
    /// Returns an `Array` containing the accumulated
    /// day count in the year.
    static func accumulatedDays(for length: Year.Length) -> [Int] {

      // Cache the results of the switch statement.
      switch length {
      case .normal: return {
        var days = [Int]()
        var total = 0
        for month in months(for: .normal) {
          total += month.days
          days.append(total)
        }
        return days
        }()
        
      case .short:  return {
        var days = [Int]()
        var total = 0
        for month in months(for: .short) {
          total += month.days
          days.append(total)
        }
        return days
        }()
      }
    }
    
    /// The sum of the number of days in the previous months.
    /// - Parameters:
    ///   - to: The month.
    ///   - for: The length of the year.
    static func dayCount(to month: Month, for length: Year.Length) -> Int {
      return Month.days(for: length)[0..<month.ordinal - 1].reduce(0, +)
      
    }
    
    /// The number of seconds in a year.
    static func seconds(for length: Year.Length) -> TimeInterval {
      return TimeInterval(days(for: length)) * Day.seconds
    }
  }
}

// MARK: - Month

extension GoddessCalendar {
  
  public struct Month {
    
    /// The number of days in the month.
    public var days: Int {
      return Month.days(for: length)[ordinal - 1]
    }
    
    // FIXME: Quick help
    /// The number of short days in the month.
    /// - Returns: The number of short days in the month if this
    /// is a short month, otherwise `nil`.
    public let length: Year.Length
    
    /// The month name.
    public var name: String {
      return Month.fullNames[ordinal - 1]
    }
    
    var seconds: TimeInterval {
      return TimeInterval(days) * Day.seconds
    }
    
    /// The ordinal position in the calendar.
    public let ordinal: Int
    
    init(ordinal: Int, length: Year.Length) {
      guard Year.months ~= ordinal else {
        preconditionFailure("Month number \(ordinal) does not exist.")
      }
      self.ordinal = ordinal
      self.length = length
    }
    
    static let fullNames = ["Athena", "Brigid", "Cerridwen", "Miranda", "Kathia", "Freya", "Gaea", "Hathor", "Inanna", "Juno", "Kore", "Lilith", "Maria"]
    
    static func days(for length: Year.Length) -> [Int] {
      
      // Cached results.
      switch length {
      case .normal: return {
        var days = [Int]()
        for ordinal in Year.months {
          switch ordinal {
          case 1, 3, 5, 7, 9, 11, 13: days.append(30)
          case 2, 4, 6, 8, 10, 12: days.append(29)
          default: assertionFailure("Switch default case reached.")
          }
        }
        return days
        }()
      case .short: return {
        var days = [Int]()
        for ordinal in Year.months {
          switch ordinal {
          case 1, 3, 5, 7, 9, 11: days.append(30)
          case 2, 4, 6, 8, 10, 12, 13: days.append(29)
          default: assertionFailure("Switch default case reached.")
          }
        }
        return days
        }()
      }
    }
    
    /// Returns an `Array` containing the accumulated
    /// seconds in each month.
    static func accumulatedSeconds(for length: Year.Length) -> [TimeInterval] {
      
      // Cached results.
      switch length {
      case .normal: return {
        var seconds = [TimeInterval]()
        var total = 0.0
        for ordinal in Year.months {
          total += Month(ordinal: ordinal, length: .normal).seconds
          seconds.append(total)
        }
        return seconds
        }()
        
      case .short:  return {
        var seconds = [TimeInterval]()
        var total = 0.0
        for ordinal in Year.months {
          total += Month(ordinal: ordinal, length: .short).seconds
          seconds.append(total)
        }
        return seconds
        }()
      }
    }
  }
}

// MARK: - Day

extension GoddessCalendar {
  
  public struct Day {
  
    let ordinal: Int
    let number: Int

    /// Returns the number of seconds in a day.
    static let seconds: TimeInterval = 86400.0
  }
}

// MARK: - Identifier

extension GoddessCalendar {
  
  /// The calendar time-zone as a 3-letter abreviation.
  static let timeZone = "MMG"
  
  /// The calendar short name.
  static let shortName = "Goddess Calendar"
  
  /// The calendar full name.
  static let fullName = "McKenna-Meyer Goddess Calendar"
}
