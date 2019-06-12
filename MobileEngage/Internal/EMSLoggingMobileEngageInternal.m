//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLoggingMobileEngageInternal.h"
#import "EMSMethodNotAllowed.h"
#import "EMSMacros.h"

#define klass [EMSLoggingMobileEngageInternal class]

@implementation EMSLoggingMobileEngageInternal

- (void)setContactWithContactFieldValue:(nullable NSString *)contactFieldValue {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:@{@"contactFieldValue": contactFieldValue}]);
}

- (void)setContactWithContactFieldValue:(nullable NSString *)contactFieldValue
                        completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSDictionary *const parameters = @{
        @"contactFieldValue": contactFieldValue,
        @"completionBlock": @(completionBlock != nil)
    };
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

- (void)clearContact {
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:nil]);
}

- (void)clearContactWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSDictionary *const parameters = @{
        @"completionBlock": @(completionBlock != nil)
    };
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

- (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes {
    NSDictionary *const parameters = @{
        @"eventName": eventName,
        @"eventAttributes": eventAttributes
    };
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}

- (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes
                 completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSDictionary *const parameters = @{
        @"eventName": eventName,
        @"eventAttributes": eventAttributes,
        @"completionBlock": @(completionBlock != nil)
    };
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters]);
}


@end