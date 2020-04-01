//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSLoggingGeofenceInternal.h"
#import "EMSMacros.h"
#import "EMSMethodNotAllowed.h"

#define proto @protocol(EMSGeofenceProtocol)

@implementation EMSLoggingGeofenceInternal

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

- (void)requestAlwaysAuthorization {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
}

- (void)enable {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
}

- (void)enableWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"completionBlock"] = @(completionBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)disable {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
}

- (BOOL)isEnabled {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
    return NO;
}

@end