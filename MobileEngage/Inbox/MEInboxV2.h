//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSRESTClient.h"
#import <Foundation/Foundation.h>
#import "MEInboxProtocol.h"
#import "MEInboxNotificationProtocol.h"
#import "MERequestContext.h"

@interface MEInboxV2 : NSObject <MEInboxNotificationProtocol>

@property(nonatomic, strong) MENotificationInboxStatus *lastNotificationStatus;
@property(nonatomic, strong) NSDate *responseTimestamp;
@property(nonatomic, strong) NSDate *purgeTimestamp;

- (instancetype)initWithConfig:(EMSConfig *)config
                requestContext:(MERequestContext *)requestContext
                    restClient:(EMSRESTClient *)restClient
                 notifications:(NSMutableArray *)notifications
             timestampProvider:(EMSTimestampProvider *)timestampProvider;

@end