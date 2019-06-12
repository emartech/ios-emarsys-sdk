//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLoggingPushInternal.h"
#import "EMSMacros.h"
#import "EMSMethodNotAllowed.h"

#define klass [EMSLoggingPushInternal class]

@implementation EMSLoggingPushInternal

- (void)setPushToken:(NSData *)pushToken {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:nil]);
}

- (void)setPushToken:(NSData *)pushToken
     completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSDictionary *const parameters = @{
        @"pushToken": pushToken,
        @"completionBlock": @(completionBlock != nil)
    };
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

- (void)clearPushToken {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:nil]);
}

- (void)clearPushTokenWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:@{
                                               @"completionBlock": @(completionBlock != nil)
                                           }]);
}

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo {
    NSDictionary *const parameters = @{
        @"userInfo": userInfo,
    };
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo
                     completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSDictionary *const parameters = @{
        @"userInfo": userInfo,
        @"completionBlock": @(completionBlock != nil)
    };
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

@end