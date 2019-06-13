//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLoggingUserNotificationDelegate.h"
#import "EMSMacros.h"
#import "EMSMethodNotAllowed.h"

#define klass [EMSLoggingUserNotificationDelegate class]

@implementation EMSLoggingUserNotificationDelegate

- (id <UNUserNotificationCenterDelegate>)delegate {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:nil]);
    return nil;
}

- (void)setDelegate:(id <UNUserNotificationCenterDelegate>)delegate {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"delegate"] = @(delegate != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

- (id <EMSEventHandler>)eventHandler {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:nil]);
    return nil;
}

- (void)setEventHandler:(id <EMSEventHandler>)eventHandler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"eventHandler"] = @(eventHandler != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

@end