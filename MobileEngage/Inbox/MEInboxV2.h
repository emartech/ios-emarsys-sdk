//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRESTClient.h"
#import "EMSRequestManager.h"
#import "MEInboxProtocol.h"
#import "MEInboxNotificationProtocol.h"
#import "MERequestContext.h"

@interface MEInboxV2 : NSObject <MEInboxNotificationProtocol>

@property(nonatomic, strong) EMSNotificationInboxStatus *lastNotificationStatus;
@property(nonatomic, strong) NSDate *responseTimestamp;
@property(nonatomic, strong) NSDate *purgeTimestamp;

- (instancetype)initWithConfig:(EMSConfig *)config
                requestContext:(MERequestContext *)requestContext
                    restClient:(EMSRESTClient *)restClient
                 notifications:(NSMutableArray *)notifications
             timestampProvider:(EMSTimestampProvider *)timestampProvider
                requestManager:(EMSRequestManager *)requestManager;

@end