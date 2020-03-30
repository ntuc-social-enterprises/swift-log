//
//  BasicFormatter.swift
//  LoggingFormatAndPipe
//
//  Created by Ian Grossberg on 7/26/19.
//

import Foundation

/// Your basic, customizable log formatter
/// `BasicFormatter` does not need any setup and will automatically include all log components
/// It can also be given a linear sequence of log components and it will build formatted logs in that order
public struct BasicFormatter: Formatter {
  /// Log format sequential specification
  public let format: [LogComponent]
  /// Log component separator
  public let separator: String?
  /// Log timestamp component formatter
  public let timestampFormatter: DateFormatter

  /// Default timestamp component formatter
  public static var timestampFormatter: DateFormatter {
    let result = DateFormatter()
    result.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return result
  }

  /// Default init
  /// - Parameters:
  ///   - _: Log format specification(default: `LogComponent.allNonmetaComponents`)
  ///   - separator: Log component separator (default: " ")
  ///   - timestampFormatter: Log timestamp component formatter (default: `BasicFormatter.timestampFormatter`)
  public init(_ format: [LogComponent] = LogComponent.allNonmetaComponents, separator: String = " ", timestampFormatter: DateFormatter = BasicFormatter.timestampFormatter) {
    self.format = format
    self.separator = separator
    self.timestampFormatter = timestampFormatter
  }

  /// Our main log formatting method
  /// - Parameters:
  ///   - level: log level
  ///   - message: actual message
  ///   - prettyMetadata: optional metadata that has already been "prettified"
  ///   - file: log's originating file
  ///   - function: log's originating function
  ///   - line: log's originating line
  /// - Returns: Result of formatting the log
  public func processLog(level: Logger.Level,
                         message: Logger.Message,
                         prettyMetadata: String?,
                         file: String, function: String, line: UInt) -> String {
    let now = Date()

    return format.map { (component) -> String in
      self.processComponent(component, now: now, level: level, message: message, prettyMetadata: prettyMetadata, file: file, function: function, line: line)
    }.filter { (string) -> Bool in
      string.count > 0
    }.joined(separator: separator ?? "")
  }

  ///
  /// `{timestamp} ▶ {contextName} ▶ {version} ▶ {level} ▶ {file}:{line} ▶ {function} ▶ {message} ▶ {metadata}`
  ///
  /// *Example:*
  ///
  /// `2020-03-30T12:29:27+0800 ▶ [Sample SDK] ▶ v0.2.0 ▶ info ▶ Sources/main.swift:98 ▶ init() ▶ SDK successfully initialised.`
  public static func standardDebugFormatter(version: String? = nil, contextName: String? = nil, separator: String = " ▶ ", timestampFormatter: DateFormatter = BasicFormatter.timestampFormatter) -> BasicFormatter {
    var components: [LogComponent] = [
      .timestamp
    ]
    if let contextName = contextName {
      components.append(.text(contextName))
    }
    if let version = version {
      components.append(.text(version))
    }
    components.append(contentsOf: [
      .level,
      .group([
        .file,
        .text(":"),
        .line
      ]),
      .function,
      .message,
      .metadata
    ])

    return BasicFormatter(components, separator: separator, timestampFormatter: timestampFormatter)
  }

  ///
  /// `{timestamp} ▶ {contextName} ▶ {version} ▶ {level} ▶ {message}`
  ///
  /// *Example:*
  ///
  /// `2020-03-30T12:15:47+0800 ▶ [Sample SDK] ▶ v0.2.0 ▶ info: ▶ Commencing authentication flow.`
  public static func standardInfoFormatter(version: String? = nil, contextName: String? = nil, separator: String = " ▶ ", timestampFormatter: DateFormatter = BasicFormatter.timestampFormatter) -> BasicFormatter {
    var components: [LogComponent] = [
      .timestamp
    ]
    if let contextName = contextName {
      components.append(.text(contextName))
    }
    if let version = version {
      components.append(.text(version))
    }
    components.append(contentsOf: [.level, .message])

    return BasicFormatter(components, separator: separator, timestampFormatter: timestampFormatter)
  }
}
