//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UserNotifications/UNUserNotificationCenter.h>
#import "EMSBlocks.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMSPushNotificationProtocol <UNUserNotificationCenterDelegate>

@property(nonatomic, weak) id <UNUserNotificationCenterDelegate> delegate;

@property(nonatomic, strong) EMSEventHandlerBlock silentMessageEventHandler;
@property(nonatomic, strong) EMSSilentNotificationInformationBlock silentMessageInformationBlock;
@property(nonatomic, strong) EMSEventHandlerBlock notificationEventHandler;
@property(nonatomic, strong) EMSSilentNotificationInformationBlock notificationInformationBlock;


- (void)setPushToken:(NSData *)pushToken;

- (void)setPushToken:(NSData *)pushToken
     completionBlock:(_Nullable EMSCompletionBlock)completionBlock
    NS_SWIFT_NAME(setPushToken(pushToken:completionBlock:));

- (nullable NSData *)pushToken;

- (void)clearPushToken;

- (void)clearPushTokenWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock
    NS_SWIFT_NAME(clearPushToken(completionBlock:));

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo
    NS_SWIFT_NAME(trackMessageOpen(userInfo:));

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo
                     completionBlock:(_Nullable EMSCompletionBlock)completionBlock
    NS_SWIFT_NAME(trackMessageOpen(userInfo:completionBlock:));

- (void)handleMessageWithUserInfo:(NSDictionary *)userInfo
    NS_SWIFT_NAME(handleMessage(userInfo:));

@end

NS_ASSUME_NONNULL_END
