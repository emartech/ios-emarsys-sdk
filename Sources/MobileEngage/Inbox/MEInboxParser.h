//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSNotification;
@class EMSNotificationInboxStatus;

@interface MEInboxParser : NSObject

- (EMSNotificationInboxStatus *)parseNotificationInboxStatus:(NSDictionary *)notificationInboxStatus;

- (NSArray<EMSNotification *> *)parseArrayOfNotifications:(NSArray *)array;

- (EMSNotification *)parseNotification:(NSDictionary *)notification;

@end