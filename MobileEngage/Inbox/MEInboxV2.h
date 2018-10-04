//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRESTClient.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "EMSInboxProtocol.h"
#import "EMSNotificationCache.h"

@interface MEInboxV2 : NSObject <EMSInboxProtocol>

@property(nonatomic, strong) EMSNotificationInboxStatus *lastNotificationStatus;
@property(nonatomic, strong) NSDate *responseTimestamp;
@property(nonatomic, strong) NSDate *purgeTimestamp;

- (instancetype)initWithConfig:(EMSConfig *)config
                requestContext:(MERequestContext *)requestContext
             notificationCache:(EMSNotificationCache *)notificationCache
                    restClient:(EMSRESTClient *)restClient
             timestampProvider:(EMSTimestampProvider *)timestampProvider
                requestManager:(EMSRequestManager *)requestManager;

@end