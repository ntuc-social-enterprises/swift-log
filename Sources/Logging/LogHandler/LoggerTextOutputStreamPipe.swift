//
//  LoggerTextOutputStreamPipe.swift
//  LoggingFormatAndPipe
//
//  Created by Ian Grossberg on 7/22/19.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Darwin
#else
import Glibc
#endif

/// A pipe for sending logs to a `TextOutputStream`
public struct LoggerTextOutputStreamPipe: Pipe {
    private let stream: TextOutputStream

    /// Default init
    /// - Parameter _: Our stream to pipe to
    public init(_ stream: TextOutputStream) {
        self.stream = stream
    }

    /// Our main log handling pipe method
    /// - Parameters:
    ///   - _: The formatted log to handle
    public func handle(_ formattedLogLine: String) {
        var stream = self.stream
        stream.write("\(formattedLogLine)\n")
    }
}

extension LoggerTextOutputStreamPipe {
    /// Pipe logs to Standard Output (stdout)
    public static var standardOutput: LoggerTextOutputStreamPipe {
        return LoggerTextOutputStreamPipe(StdioOutputStream.stdout)
    }

    /// Pipe logs to Standard Error (stderr)
    public static var standardError: LoggerTextOutputStreamPipe {
        return LoggerTextOutputStreamPipe(StdioOutputStream.stderr)
    }

}
