//
// Copyright (c) 2022 Emarsys. All rights reserved.
//

import os
import Foundation

@available(iOS 14.0, *)
@available(macOS 11.0, *)
class SDKLogger {
    private static let subsystem = "com.emarsys"
    private static let category = "EmarsysSDK"
    private static let EMSLoggingEndpoint: String = "https://log-dealer.eservice.emarsys.net/v1/log"
    static let maxColumns = 8

    private var loggerLogLevel: LogLevel
    private var consoleLogLevels: Array<LogLevel>
    private var savedLogLevel: LogLevel?

    init() {
        savedLogLevel = nil
        loggerLogLevel = savedLogLevel != nil ? savedLogLevel! : LogLevel.Error
        consoleLogLevels = [LogLevel.Warn, LogLevel.Error, LogLevel.Trace, LogLevel.Info,
                            LogLevel.Debug]
    }

    private let logger = Logger(subsystem: subsystem, category: category)

    func setConsoleLogLevels(logLevels: Array<LogLevel>) {
        consoleLogLevels = logLevels
    }

    func resetLogLevel() {
        loggerLogLevel = LogLevel.Error
        savedLogLevel = nil
    }

    public func log(logEntry: LogEntry, level: LogLevel) {
        logToConsole(logEntry: logEntry, level: level)

        let url: String? = logEntry.data["url"] as! String?
        if !(logEntry.topic == "log_request" && url != nil && url == SDKLogger.EMSLoggingEndpoint) && level.rawValue >= loggerLogLevel.rawValue || logEntry.topic == "app:start" {
            saveLogToDatabase()
        }
    }

    private func logToConsole(logEntry: LogEntry, level: LogLevel) {
        if (consoleLogLevels.contains(LogLevel.Basic) && logEntry.topic == "log_method_not_allowed") {
            debugLog(logEntry: logEntry)
        } else if (consoleLogLevels.contains(level)) {
            switch (level) {
            case .Trace: traceLog(logEntry: logEntry)
            case .Debug: debugLog(logEntry: logEntry)
            case .Info: infoLog(logEntry: logEntry)
            case .Warn: warningLog(logEntry: logEntry)
            case .Error: errorLog(logEntry: logEntry)
            default: return
            }
        }
    }

    private func saveLogToDatabase() {
        print("Log saved")
    }

    private func debugLog(logEntry: LogEntry) {
        logEntry.hideSensitiveData ?
                logger.debug("\("DEBUG", align: .left(columns: SDKLogger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .private)") :
                logger.debug("\("DEBUG", align: .left(columns: SDKLogger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .public)")
    }

    private func infoLog(logEntry: LogEntry) {
        logEntry.hideSensitiveData ?
                logger.info("\("INFO", align: .left(columns: SDKLogger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .private)") :
                logger.info("\("INFO", align: .left(columns: SDKLogger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .public)")
    }

    private func warningLog(logEntry: LogEntry) {
        logEntry.hideSensitiveData ?
                logger.error("\("WARNING", align: .left(columns: SDKLogger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .private)") :
                logger.error("\("WARNING", align: .left(columns: SDKLogger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .public)")
    }

    private func errorLog(logEntry: LogEntry) {
        logEntry.hideSensitiveData ?
                logger.fault("\("ERROR", align: .left(columns: SDKLogger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .private)") :
                logger.fault("\("ERROR", align: .left(columns: SDKLogger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .public)")
    }

    private func traceLog(logEntry: LogEntry) {
        logEntry.hideSensitiveData ?
                logger.debug("\("DEBUG", align: .left(columns: SDKLogger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .private)") :
                logger.debug("\("DEBUG", align: .left(columns: SDKLogger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .public)")
    }
}
