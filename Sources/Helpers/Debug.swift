// Nisroc

import Cocoa

// MARK: Logger
enum LogLevel: String {
  case none = ""
  case passed = "✅ "
  case warning = "⚠️ "
  case error = "‼️ "
}

/// Outputs the given item to the standard console,
/// along with the calling class and function name.
///
/// - Parameters:
///   - item: The object to print to the console.
///   - level: The log level as defined in the LogLevel enum.
///   - fileName: The callers filename.
///   - function: The callers function.
///
func logln(_ item: Any, level: LogLevel = .none, fileName: String = #file, function: String = #function) {
  let className = URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
  print("————————————————————————————————————\n\(className).\(function)\n\(level.rawValue)\(item)\n")
}


func logdiff<T: AdditiveArithmetic>(_ lhs: T, _ rhs: T, fileName: String = #file, function: String = #function) {
  let className = URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
 
  let diff = lhs - rhs
  var level = LogLevel.passed
  if diff != T.zero { level = LogLevel.error }
  print("————————————————————————————————————\n\(className).\(function) \(level.rawValue)\nOffered: \(lhs)\nExpected: \(rhs)\nDifference: \(diff)")
}
