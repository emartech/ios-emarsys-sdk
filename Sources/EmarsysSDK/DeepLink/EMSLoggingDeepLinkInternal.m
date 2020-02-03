//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLoggingDeepLinkInternal.h"
#import "EMSMacros.h"
#import "EMSMethodNotAllowed.h"
#import "Emarsys.h"

#define klass [Emarsys class]

@implementation EMSLoggingDeepLinkInternal

- (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(_Nullable EMSSourceHandler)sourceHandler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"userActivity"] = [userActivity description];
    parameters[@"sourceHandler"] = @(sourceHandler != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
    return NO;
}

- (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(_Nullable EMSSourceHandler)sourceHandler
      withCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"userActivity"] = [userActivity description];
    parameters[@"sourceHandler"] = @(sourceHandler != nil);
    parameters[@"completionBlock"] = @(completionBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
    return NO;
}

@end