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
                                              parameters:nil], LogLevelDebug);
}

- (void)setPushToken:(NSData *)pushToken
     completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"pushToken"] = [pushToken deviceTokenString];
    parameters[@"completionBlock"] = @(completionBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (NSData *)pushToken {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
    return nil;
}

- (void)clearPushToken {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
}

- (void)clearPushTokenWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"completionBlock"] = @(completionBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"userInfo"] = userInfo;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo
                     completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"userInfo"] = userInfo;
    parameters[@"completionBlock"] = @(completionBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (void)handleMessageWithUserInfo:(NSDictionary *)userInfo {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"userInfo"] = userInfo;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (id)silentMessageEventHandler {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
    return nil;
}

- (void)setSilentMessageEventHandler:(id)silentMessageEventHandler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"silentMessageEventHandler"] = @(silentMessageEventHandler != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (id)silentNotificationInformationDelegate {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
    return nil;
}

- (void)setSilentNotificationInformationDelegate:(id)silentNotificationInformationDelegate {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"silentNotificationInformationDelegate"] = @(silentNotificationInformationDelegate != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:parameters], LogLevelDebug);
}

- (NSData *)deviceToken {
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:nil], LogLevelDebug);
    return nil;
}

@end