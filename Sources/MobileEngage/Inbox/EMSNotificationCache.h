//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSNotification.h"

@interface EMSNotificationCache : NSObject

- (void)cache:(EMSNotification *)notification;

- (NSArray<EMSNotification *> *)mergeWithNotifications:(NSArray<EMSNotification *> *)notifications;

- (NSArray<EMSNotification *> *)notifications;

@end