//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSNotificationInboxStatus.h"
#import "MERequestContext.h"
#import "EMSInboxProtocol.h"

@class EMSRESTClient;
@class EMSRequestManager;

@interface MEInbox : NSObject <EMSInboxProtocol>

- (instancetype)initWithConfig:(EMSConfig *)config
                requestContext:(MERequestContext *)requestContext
                    restClient:(EMSRESTClient *)restClient
                requestManager:(EMSRequestManager *)requestManager;

- (NSMutableArray *)notifications;

- (MERequestContext *)requestContext;

@end
