//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSNotificationInboxStatus.h"
#import "MERequestContext.h"
#import "EMSInboxProtocol.h"

@class EMSRESTClient;
@class EMSRequestManager;
@class EMSNotificationCache;
@class EMSRequestFactory;

@interface MEInbox : NSObject <EMSInboxProtocol>

- (instancetype)initWithConfig:(EMSConfig *)config
                requestContext:(MERequestContext *)requestContext
             notificationCache:(EMSNotificationCache *)notificationCache
                requestManager:(EMSRequestManager *)requestManager
                requestFactory:(EMSRequestFactory *)requestFactory;

@end
