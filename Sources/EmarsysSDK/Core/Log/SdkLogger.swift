//
// Copyright (c) 2022 Emarsys. All rights reserved.
//

import os
import Foundation


@SdkActor
class SdkLogger {
    private let defaultUrls: DefaultUrls
    private let logger: Logger
    private var loggerLogLevel: OSLogType
    private var savedLogLevel: OSLogType?


    init(defaultUrls: DefaultUrls, logger: Logger) {
        savedLogLevel = nil
        self.defaultUrls = defaultUrls
        self.logger = logger
        loggerLogLevel = savedLogLevel != nil ? savedLogLevel! : .error
    }

    func resetLogLevel() {
        loggerLogLevel = .error
        savedLogLevel = nil
    }

    func log(logEntry: LogEntry, level: OSLogType) {
        logToConsole(logEntry: logEntry, level: level)

        let url: String? = logEntry.data["url"] as! String?
        if !(logEntry.topic == "log_request" && url != nil && url == defaultUrls.loggingUrl) && level.rawValue >= loggerLogLevel.rawValue || logEntry.topic == "app:start" {
            sendRemoteLog()
        }
    }

    private func logToConsole(logEntry: LogEntry, level: OSLogType) {
        if logEntry.hideSensitiveData {
            logger.log(level: level, "\(Constants.Logger.category, align: .left(columns: Constants.Logger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .private)")
        } else {
            logger.log(level: level, "\(Constants.Logger.category, align: .left(columns: Constants.Logger.maxColumns), privacy: .public) - \(logEntry.topic) Data: \(logEntry.data, privacy: .public)")
        }
    }

    private func sendRemoteLog() {
        //TODO send log to logDealer
    }
}
