//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLoggingInApp.h"
#import "EMSMethodNotAllowed.h"
#import "EMSMacros.h"

#define proto @protocol(EMSInAppProtocol)

@implementation EMSLoggingInApp

- (id <EMSEventHandler>)eventHandler {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
    return nil;
}

- (void)setEventHandler:(id <EMSEventHandler>)eventHandler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"eventHandler"] = @(eventHandler != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)pause {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
}

- (void)resume {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
}

- (BOOL)isPaused {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
    return NO;
}

- (id <MEInAppTrackingProtocol>)inAppTracker {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
    return nil;
}

- (MEInAppMessage *)currentInAppMessage {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
    return nil;
}

- (void)closeInAppMessageWithCompletionBlock:(MECompletionHandler)completionHandler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"completionHandler"] = @(completionHandler != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)setInAppTracker:(id <MEInAppTrackingProtocol>)inAppTracker {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"inAppTracker"] = [inAppTracker description];
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

@end