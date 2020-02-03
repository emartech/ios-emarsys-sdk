//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSNotificationCache.h"

@interface EMSNotificationCache ()

@property(nonatomic, strong) NSMutableArray<EMSNotification *> *notificationCache;

@end

@implementation EMSNotificationCache

- (instancetype)init {
    self = [super init];
    if (self) {
        _notificationCache = [NSMutableArray new];
    }
    return self;
}

- (void)cache:(EMSNotification *)notification {
    if (notification) {
        [self.notificationCache insertObject:notification
                                     atIndex:0];
    }
}

- (NSArray<EMSNotification *> *)mergeWithNotifications:(NSArray<EMSNotification *> *)notifications {
    [self invalidateCachedNotifications:notifications];

    if (!notifications) {
        notifications = @[];
    }

    NSMutableArray<EMSNotification *> *result = [NSMutableArray new];
    [result addObjectsFromArray:self.notificationCache];
    [result addObjectsFromArray:notifications];

    return [NSArray arrayWithArray:result];
}


- (NSArray<EMSNotification *> *)notifications {
    return [NSArray arrayWithArray:self.notificationCache];
}

- (void)invalidateCachedNotifications:(NSArray<EMSNotification *> *)notifications {
    for (int i = (int) [self.notificationCache count] - 1; i >= 0; --i) {
        EMSNotification *notification = self.notificationCache[(NSUInteger) i];
        for (EMSNotification *currentNotification in notifications) {
            if ([currentNotification.id isEqual:notification.id]) {
                [self.notificationCache removeObjectAtIndex:(NSUInteger) i];
                break;
            }
        }
    }
}


@end