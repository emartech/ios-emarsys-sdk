//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRESTClient.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "EMSInboxProtocol.h"
#import "EMSNotificationCache.h"

@class EMSRequestFactory;

@interface MEInboxV2 : NSObject <EMSInboxProtocol>

@property(nonatomic, strong) EMSNotificationInboxStatus *lastNotificationStatus;
@property(nonatomic, strong) NSDate *responseTimestamp;
@property(nonatomic, strong) NSDate *purgeTimestamp;

- (instancetype)initWithConfig:(EMSConfig *)config
                requestContext:(MERequestContext *)requestContext
             notificationCache:(EMSNotificationCache *)notificationCache
                requestManager:(EMSRequestManager *)requestManager
                requestFactory:(EMSRequestFactory *)requestFactory;

@end