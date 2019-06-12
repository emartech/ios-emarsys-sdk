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
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:@{@"eventHandler": @(eventHandler != nil)}]);
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


@end