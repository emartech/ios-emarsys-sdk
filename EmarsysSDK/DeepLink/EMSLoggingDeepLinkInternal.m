//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLoggingDeepLinkInternal.h"
#import "EMSMacros.h"
#import "EMSMethodNotAllowed.h"

#define klass [EMSLoggingDeepLinkInternal class]

@implementation EMSLoggingDeepLinkInternal

- (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(_Nullable EMSSourceHandler)sourceHandler {
    NSDictionary *const parameters = @{
        @"userActivity": userActivity,
        @"sourceHandler": @(sourceHandler != nil)
    };
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
    return NO;
}

- (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(_Nullable EMSSourceHandler)sourceHandler
      withCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSDictionary *const parameters = @{
        @"userActivity": userActivity,
        @"sourceHandler": @(sourceHandler != nil),
        @"completionBlock": @(completionBlock != nil)
    };
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
    return NO;
}

@end