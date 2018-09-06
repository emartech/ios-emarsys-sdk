//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSNotification;
@class MENotificationInboxStatus;

@interface MEInboxParser : NSObject

- (MENotificationInboxStatus *)parseNotificationInboxStatus:(NSDictionary *)notificationInboxStatus;

- (NSArray<EMSNotification *> *)parseArrayOfNotifications:(NSArray *)array;

- (EMSNotification *)parseNotification:(NSDictionary *)notification;

@end