//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@protocol EMSPushNotificationProtocol <NSObject>

- (void)setPushToken:(NSData *)pushToken;

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo;

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo
                     completionBlock:(EMSCompletionBlock)completionBlock;

@end