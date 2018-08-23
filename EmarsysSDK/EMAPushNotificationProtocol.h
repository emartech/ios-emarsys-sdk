//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMAConstants.h"

@protocol EMAPushNotificationProtocol <NSObject>

+ (void)setPushToken:(NSString *)pushToken;

+ (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo
                         resultBlock:(EMAResultBlock)resultBlock;

@end