//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMAConstants.h"

@class MENotification;

@protocol EMAInboxProtocol <NSObject>

- (void)fetchNotificationsWithResultBlock:(MEInboxResultBlock)resultBlock
                               errorBlock:(MEInboxResultErrorBlock)errorBlock;

- (void)resetBadgeCountWithSuccessBlock:(MEInboxSuccessBlock)successBlock
                             errorBlock:(MEInboxResultErrorBlock)errorBlock;

- (void)resetBadgeCount;

- (void)trackMessageOpenWithInboxMessage:(MENotification *)inboxMessage
                             resultBlock:(EMAResultBlock)resultBlock;

- (void)purgeNotificationCache;

@end