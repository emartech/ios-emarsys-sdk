//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation


struct LoggingConfig: ConfigInstance {
    let logger: SdkLogger
    
    func changeApplicationCode(applicationCode: String) async throws {
        let entry = LogEntry.createMethodNotAllowedEntry(source: self,
                                                         params: ["applicationCode": applicationCode])
        logger.log(logEntry: entry, level: .debug)
    }
    
    func changeMerchantId(merchantId: String) async throws {
        let entry = LogEntry.createMethodNotAllowedEntry(source: self,
                                                         params: ["merchantId": merchantId])
        logger.log(logEntry: entry, level: .debug)
    }
}
