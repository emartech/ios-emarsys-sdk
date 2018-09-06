//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSConfig;
@class MENotificationInboxStatus;
@class EMSNotification;

typedef void (^MEInboxSuccessBlock)(void);
typedef void (^MEInboxResultBlock)(MENotificationInboxStatus *inboxStatus);
typedef void (^MEInboxResultErrorBlock)(NSError *error);

@protocol MEInboxProtocol <NSObject>

- (void)fetchNotificationsWithResultBlock:(MEInboxResultBlock)resultBlock
                               errorBlock:(MEInboxResultErrorBlock)errorBlock;

- (void)resetBadgeCountWithSuccessBlock:(MEInboxSuccessBlock)successBlock
                             errorBlock:(MEInboxResultErrorBlock)errorBlock;

- (void)resetBadgeCount;

- (NSString *)trackMessageOpenWithInboxMessage:(EMSNotification *)inboxMessage;

- (void)purgeNotificationCache;

@end