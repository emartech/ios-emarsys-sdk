//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol EMSPushNotificationProtocol <NSObject>

+ (void)setPushToken:(NSString *)pushToken;

+ (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo;

+ (void)trackMessageOpenWith:(NSDictionary *)userInfo
             completionBlock:(EMSCompletionBlock)completionBlock;

@end