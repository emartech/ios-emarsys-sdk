//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLoggingInApp.h"
#import "EMSMethodNotAllowed.h"
#import "EMSMacros.h"

#define klass [EMSLoggingInApp class]

@implementation EMSLoggingInApp

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

- (void)pause {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:nil]);
}

- (void)resume {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:nil]);
}

- (BOOL)isPaused {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:nil]);
    return NO;
}

- (id <MEInAppTrackingProtocol>)inAppTracker {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:nil]);
    return nil;
}

- (NSString *)currentCampaignId {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:nil]);
    return nil;
}

- (void)closeInAppMessageWithCompletionBlock:(MECompletionHandler)completionHandler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"completionHandler"] = @(completionHandler != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

- (void)setInAppTracker:(id <MEInAppTrackingProtocol>)inAppTracker {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"inAppTracker"] = [inAppTracker description];
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

@end