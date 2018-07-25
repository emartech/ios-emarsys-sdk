//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEInboxParser.h"
#import "MENotification.h"
#import "MENotificationInboxStatus.h"

@implementation MEInboxParser

- (MENotificationInboxStatus *)parseNotificationInboxStatus:(NSDictionary *)notificationInboxStatus {
    MENotificationInboxStatus *result = [MENotificationInboxStatus new];
    NSArray<NSDictionary *> *notificationDicts = notificationInboxStatus[@"notifications"];
    NSUInteger badgeCount = [notificationInboxStatus[@"badge_count"] unsignedIntegerValue];
    [result setNotifications:[self parseArrayOfNotifications:notificationDicts]];
    [result setBadgeCount:badgeCount];
    return result;
}

- (NSArray<MENotification *> *)parseArrayOfNotifications:(NSArray<NSDictionary *> *)array {
    NSMutableArray<MENotification *> *results = [NSMutableArray new];
    for (NSDictionary *notificationDict in array) {
        [results addObject:[self parseNotification:notificationDict]];
    }
    return [NSArray arrayWithArray:results];
}

- (MENotification *)parseNotification:(NSDictionary *)notification {
    return [[MENotification alloc] initWithNotificationDictionary:notification];
}

@end