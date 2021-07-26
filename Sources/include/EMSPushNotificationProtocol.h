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
     completionBlock:(_Nullable EMSCompletionBlock)completionBlock;

- (nullable NSData *)pushToken;

- (void)clearPushToken;

- (void)clearPushTokenWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock;

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo;

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo
                     completionBlock:(_Nullable EMSCompletionBlock)completionBlock;

- (void)handleMessageWithUserInfo:(NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
