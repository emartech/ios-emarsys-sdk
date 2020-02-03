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
@class EMSEndpoint;

@interface MEInbox : NSObject <EMSInboxProtocol>

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext
                     notificationCache:(EMSNotificationCache *)notificationCache
                        requestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                              endpoint:(EMSEndpoint *)endpoint;

@end
