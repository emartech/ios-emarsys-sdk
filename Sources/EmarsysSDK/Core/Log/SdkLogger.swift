//
// Copyright (c) 2022 Emarsys. All rights reserved.
//

import os
import Foundation


@SdkActor
class SdkLogger {
    private let defaultUrls: DefaultUrls
    private let logger: Logger
    private var loggerLogLevel: LogLevel
    private var consoleLogLevels: [LogLevel]
    private var savedLogLevel: LogLevel?
    

    init(defaultUrls: DefaultUrls, logger: Logger) {
        savedLogLevel = nil
        self.defaultUrls = defaultUrls
        self.logger = logger
        loggerLogLevel = savedLogLevel != nil ? savedLogLevel! : LogLevel.error
        consoleLogLevels = [LogLevel.warn, LogLevel.error, LogLevel.trace, LogLevel.info,
                            LogLevel.debug]
    }

    func setConsoleLogLevels(logLevels: Array<LogLevel>) {
        consoleLogLevels = logLevels
    }

    func resetLogLevel() {
        loggerLogLevel = LogLevel.error
        savedLogLevel = nil
    }

    public func log(logEntry: LogEntry, level: LogLevel) {
        logToConsole(logEntry: logEntry, level: level)

        let url: String? = logEntry.data["url"] as! String?
        if !(logEntry.topic == "log_request" && url != nil && url == defaultUrls.loggingUrl) && level.rawValue >= loggerLogLevel.rawValue || logEntry.topic == "app:start" {
            saveLogToDatabase()
        }
    }

    private func logToConsole(logEntry: LogEntry, level: LogLevel) {
        if (logEntry.topic == "log_method_not_allowed") {
            warningLog(logEntry: logEntry)
        } else if (consoleLogLevels.contains(level)) {
            switch (level) {
            case .basic: debugLog(logEntry: logEntry)
            case .trace: traceLog(logEntry: logEntry)
            case .debug: debugLog(logEntry: logEntry)
            case .info: infoLog(logEntry: logEntry)
            case .warn: warningLog(logEntry: logEntry)
            case .error: errorLog(logEntry: logEntry)
            default: return
            }
        }
    }

    private func saveLogToDatabase() {
        print("Log saved")
    }

    private func debugLog(logEntry: LogEntry) {
        logEntry.hideSensitiveData ?
        logger.debug("\("DEBUG", align: .left(columns: Constants.Logger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .private)") :
                logger.debug("\("DEBUG", align: .left(columns: Constants.Logger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .public)")
    }

    private func infoLog(logEntry: LogEntry) {
        logEntry.hideSensitiveData ?
                logger.info("\("INFO", align: .left(columns: Constants.Logger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .private)") :
                logger.info("\("INFO", align: .left(columns: Constants.Logger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .public)")
    }

    private func warningLog(logEntry: LogEntry) {
        logEntry.hideSensitiveData ?
                logger.error("\("WARNING", align: .left(columns: Constants.Logger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .private)") :
                logger.error("\("WARNING", align: .left(columns: Constants.Logger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .public)")
    }

    private func errorLog(logEntry: LogEntry) {
        logEntry.hideSensitiveData ?
                logger.fault("\("ERROR", align: .left(columns: Constants.Logger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .private)") :
                logger.fault("\("ERROR", align: .left(columns: Constants.Logger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .public)")
    }

    private func traceLog(logEntry: LogEntry) {
        logEntry.hideSensitiveData ?
                logger.debug("\("DEBUG", align: .left(columns: Constants.Logger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .private)") :
                logger.debug("\("DEBUG", align: .left(columns: Constants.Logger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .public)")
    }
}
