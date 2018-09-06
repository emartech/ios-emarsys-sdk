//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@class EMSNotification;
@class EMSNotificationInboxStatus;

NS_ASSUME_NONNULL_BEGIN

@protocol EMSInboxProtocol <NSObject>

typedef void (^EMSFetchNotificationResultBlock)(EMSNotificationInboxStatus* _Nullable inboxStatus, NSError* _Nullable error);

- (void)fetchNotificationsWithResultBlock:(EMSFetchNotificationResultBlock)resultBlock;

- (void)resetBadgeCount;

- (void)resetBadgeCountWithCompletionBlock:(EMSCompletionBlock)completionBlock;

- (NSString *)trackNotificationOpenWithNotification:(EMSNotification *)inboxNotification;

- (NSString *)trackMessageOpenWith:(EMSNotification *)inboxMessage
                   completionBlock:(EMSCompletionBlock)completionBlock;

- (void)purgeNotificationCache;

@end

NS_ASSUME_NONNULL_END