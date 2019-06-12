//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLoggingInbox.h"
#import "EMSMacros.h"
#import "EMSMethodNotAllowed.h"

#define klass [EMSLoggingInbox class]

@implementation EMSLoggingInbox

- (void)fetchNotificationsWithResultBlock:(EMSFetchNotificationResultBlock)resultBlock {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:@{@"resultBlock": @(resultBlock != nil)}]);
}

- (void)resetBadgeCount {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:nil]);
}

- (void)resetBadgeCountWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:@{@"completionBlock": @(completionBlock != nil)}]);
}

- (void)trackNotificationOpenWithNotification:(EMSNotification *)notification {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:@{@"notification": notification}]);
}

- (void)trackNotificationOpenWithNotification:(EMSNotification *)notification
                              completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSDictionary *const parameters = @{
        @"completionBlock": @(completionBlock != nil),
        @"notification": notification
    };
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

@end