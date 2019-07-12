//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLoggingPushInternal.h"
#import "EMSMacros.h"
#import "EMSMethodNotAllowed.h"
#import "NSData+MobileEngine.h"

#define proto @protocol(EMSPushNotificationProtocol)

@implementation EMSLoggingPushInternal

- (void)setPushToken:(NSData *)pushToken {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil]);
}

- (void)setPushToken:(NSData *)pushToken
     completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"pushToken"] = [pushToken deviceTokenString];
    parameters[@"completionBlock"] = @(completionBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters]);
}

- (void)clearPushToken {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil]);
}

- (void)clearPushTokenWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"completionBlock"] = @(completionBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters]);
}

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"userInfo"] = userInfo;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters]);
}

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo
                     completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"userInfo"] = userInfo;
    parameters[@"completionBlock"] = @(completionBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters]);
}

@end