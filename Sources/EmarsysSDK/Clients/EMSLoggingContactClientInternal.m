////
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

#import "EMSLoggingContactClientInternal.h"
#import "EMSMethodNotAllowed.h"
#import "EMSMacros.h"

#define klass [EMSLoggingContactClientInternal class]

@implementation EMSLoggingContactClientInternal

- (void)clearContact { 
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters], LogLevelDebug);
}

- (void)clearContactWithCompletionBlock:(EMSCompletionBlock _Nullable)completionBlock { 
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"completionBlock"] = @(completionBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters], LogLevelDebug);
}

- (void)setAuthenticatedContactWithContactFieldId:(nullable NSNumber *)contactFieldId 
                                      openIdToken:(nullable NSString *)openIdToken
                                  completionBlock:(EMSCompletionBlock _Nullable)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"contactFieldId"] = contactFieldId;
    parameters[@"openIdToken"] = openIdToken;
    parameters[@"completionBlock"] = @(completionBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters], LogLevelDebug);
}

- (void)setContactWithContactFieldId:(nullable NSNumber *)contactFieldId 
                   contactFieldValue:(nullable NSString *)contactFieldValue {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"contactFieldId"] = contactFieldId;
    parameters[@"contactFieldValue"] = contactFieldValue;
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters], LogLevelDebug);
}

- (void)setContactWithContactFieldId:(nullable NSNumber *)contactFieldId 
                   contactFieldValue:(nullable NSString *)contactFieldValue
                     completionBlock:(EMSCompletionBlock _Nullable)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"contactFieldId"] = contactFieldId;
    parameters[@"contactFieldValue"] = contactFieldValue;
    parameters[@"completionBlock"] = @(completionBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters], LogLevelDebug);
}

@end
