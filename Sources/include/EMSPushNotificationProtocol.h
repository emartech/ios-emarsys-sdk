//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMSPushNotificationProtocol <NSObject>

@property(nonatomic, strong) EMSEventHandlerBlock silentMessageEventHandler;
@property(nonatomic, strong) EMSSilentNotificationInformationBlock silentNotificationInformationDelegate;


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
