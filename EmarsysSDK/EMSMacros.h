//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSDependencyInjection.h"
#import "EMSDependencyContainer.h"
#import "EMSLogger.h"

#define EMSLog(logEntry) [EMSDependencyInjection.dependencyContainer.logger log:logEntry];
