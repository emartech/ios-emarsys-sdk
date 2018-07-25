//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MENotification.h"

@interface MENotificationInboxStatus : NSObject

@property(nonatomic, strong) NSArray<MENotification *> *notifications;
@property(nonatomic, assign) NSUInteger badgeCount;

@end