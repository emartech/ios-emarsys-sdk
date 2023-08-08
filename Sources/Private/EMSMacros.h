//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSDependencyInjection.h"
#import "EMSDependencyContainer.h"
#import "EMSLogger.h"

#define EMSLog(logEntry, logLevel) [EMSDependencyInjection.dependencyContainer.logger log:logEntry level:logLevel];

#define EMSStrictLog(logEntry, entryLogLevel) \
    EMSLogger *logger = EMSDependencyInjection.dependencyContainer.logger; \
    if (logger.logLevel == entryLogLevel) {             \
        [logger log:logEntry level:entryLogLevel];               \
    }