//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import "EMSLoggingOnEventActionInternal.h"
#import "EMSMacros.h"
#import "EMSMethodNotAllowed.h"

#define proto @protocol(EMSOnEventActionProtocol)

@implementation EMSLoggingOnEventActionInternal


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

@end
