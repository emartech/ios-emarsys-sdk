//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSLoggingInboxV3.h"
#import "EMSMacros.h"
#import "EMSMethodNotAllowed.h"

#define proto @protocol(EMSMessageInboxProtocol)

@implementation EMSLoggingInboxV3

- (void)fetchMessagesWithResultBlock:(EMSInboxMessageResultBlock)resultBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"resultBlock"] = @(resultBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:[NSDictionary dictionaryWithDictionary:parameters]], LogLevelDebug);
}

- (void)addTag:(NSString *)tag
    forMessage:(NSString *)messageId {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"tag"] = tag;
    parameters[@"messageId"] = messageId;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:[NSDictionary dictionaryWithDictionary:parameters]], LogLevelDebug);
}

- (void) addTag:(NSString *)tag
     forMessage:(NSString *)messageId
completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"tag"] = tag;
    parameters[@"messageId"] = messageId;
    parameters[@"completionBlock"] = @(completionBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:[NSDictionary dictionaryWithDictionary:parameters]], LogLevelDebug);
}

- (void)removeTag:(NSString *)tag
      fromMessage:(NSString *)messageId {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"tag"] = tag;
    parameters[@"messageId"] = messageId;
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:[NSDictionary dictionaryWithDictionary:parameters]], LogLevelDebug);
}

- (void)removeTag:(NSString *)tag
      fromMessage:(NSString *)messageId
  completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"tag"] = tag;
    parameters[@"messageId"] = messageId;
    parameters[@"completionBlock"] = @(completionBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithProtocol:proto
                                                     sel:_cmd
                                              parameters:[NSDictionary dictionaryWithDictionary:parameters]], LogLevelDebug);
}

@end