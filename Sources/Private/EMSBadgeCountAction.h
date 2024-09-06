//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSActionProtocol.h"
#import <UIKit/UIKit.h>

@class UNUserNotificationCenter;

@interface EMSBadgeCountAction : NSObject<EMSActionProtocol>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithActionDictionary:(NSDictionary<NSString *, id> *)action
                             application:(UIApplication *)application
                  userNotificationCenter:(UNUserNotificationCenter *)userNotificationCenter
                          operationQueue:(NSOperationQueue *)operationQueue;

@end
