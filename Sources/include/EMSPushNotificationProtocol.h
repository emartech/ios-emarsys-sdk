//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@protocol EMSEventHandler;
@protocol EMSNotificationInformationDelegate;

NS_ASSUME_NONNULL_BEGIN

@protocol EMSPushNotificationProtocol <NSObject>

@property(nonatomic, weak) id <EMSEventHandler> silentMessageEventHandler;
@property(nonatomic, weak) id <EMSNotificationInformationDelegate> silentNotificationInformationDelegate;

- (void)setPushToken:(NSData *)pushToken;

- (void)setPushToken:(NSData *)pushToken
     completionBlock:(_Nullable EMSCompletionBlock)completionBlock;

- (void)clearPushToken;

- (void)clearPushTokenWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock;

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo;

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo
                     completionBlock:(_Nullable EMSCompletionBlock)completionBlock;

- (void)handleMessageWithUserInfo:(NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
