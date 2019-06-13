//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLoggingInbox.h"
#import "EMSMacros.h"
#import "EMSMethodNotAllowed.h"

#define klass [EMSLoggingInbox class]

@implementation EMSLoggingInbox

- (void)fetchNotificationsWithResultBlock:(EMSFetchNotificationResultBlock)resultBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"resultBlock"] = @(resultBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

- (void)resetBadgeCount {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:nil]);
}

- (void)resetBadgeCountWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"completionBlock"] = @(completionBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

- (void)trackNotificationOpenWithNotification:(EMSNotification *)notification {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"notification"] = [notification description];
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

- (void)trackNotificationOpenWithNotification:(EMSNotification *)notification
                              completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"completionBlock"] = @(completionBlock != nil);
    parameters[@"notification"] = [notification description];
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

@end