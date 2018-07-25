//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MENotification;
@class MENotificationInboxStatus;

@interface MEInboxParser : NSObject

- (MENotificationInboxStatus *)parseNotificationInboxStatus:(NSDictionary *)notificationInboxStatus;

- (NSArray<MENotification *> *)parseArrayOfNotifications:(NSArray *)array;

- (MENotification *)parseNotification:(NSDictionary *)notification;

@end