//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLoggingUserNotificationDelegate.h"
#import "EMSMacros.h"
#import "EMSMethodNotAllowed.h"

#define proto @protocol(EMSUserNotificationCenterDelegate)

@implementation EMSLoggingUserNotificationDelegate

- (id <UNUserNotificationCenterDelegate>)delegate {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
    return nil;
}

- (void)setDelegate:(id <UNUserNotificationCenterDelegate>)delegate {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"delegate"] = @(delegate != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (EMSEventHandlerBlock)eventHandler {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
    return nil;
}

- (void)setEventHandler:(EMSEventHandlerBlock)eventHandler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"eventHandler"] = @(eventHandler != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (id)notificationInformationDelegate {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
    return nil;
}

- (void)setNotificationInformationDelegate:(id)notificationInformationDelegate {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"notificationInformationDelegate"] = @(notificationInformationDelegate != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}


@end