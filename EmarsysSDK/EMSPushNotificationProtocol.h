//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@protocol EMSPushNotificationProtocol <NSObject>

- (void)setPushToken:(NSData *)pushToken;

- (void)setPushToken:(NSData *)pushToken
     completionBlock:(EMSCompletionBlock)completionBlock;

- (void)clearPushToken;

- (void)clearPushTokenWithCompletionBlock:(EMSCompletionBlock)completionBlock;

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo;

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo
                     completionBlock:(EMSCompletionBlock)completionBlock;

@end