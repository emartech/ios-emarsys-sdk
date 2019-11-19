//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EmarsysSDK/EMSBlocks.h>
#import <EmarsysSDK/EMSNotification.h>
#import <EmarsysSDK/EMSNotificationInboxStatus.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EMSInboxProtocol <NSObject>

typedef void (^EMSFetchNotificationResultBlock)(EMSNotificationInboxStatus* _Nullable inboxStatus, NSError* _Nullable error);

- (void)fetchNotificationsWithResultBlock:(EMSFetchNotificationResultBlock)resultBlock;

- (void)resetBadgeCount;

- (void)resetBadgeCountWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock;

- (void)trackNotificationOpenWithNotification:(EMSNotification *)notification;

- (void)trackNotificationOpenWithNotification:(EMSNotification *)notification
                              completionBlock:(_Nullable EMSCompletionBlock)completionBlock;
@end

NS_ASSUME_NONNULL_END
