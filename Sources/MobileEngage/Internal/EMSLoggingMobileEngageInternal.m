//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLoggingMobileEngageInternal.h"
#import "EMSMethodNotAllowed.h"
#import "EMSMacros.h"
#import "Emarsys.h"

#define klass [Emarsys class]

@implementation EMSLoggingMobileEngageInternal

- (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"eventName"] = eventName;
    parameters[@"eventAttributes"] = eventAttributes;
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters], LogLevelDebug);
}

- (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes
                 completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"eventName"] = eventName;
    parameters[@"eventAttributes"] = eventAttributes;
    parameters[@"completionBlock"] = @(completionBlock != nil);
    EMSLog([[EMSMethodNotAllowed alloc] initWithClass:klass
                                                  sel:_cmd
                                           parameters:parameters], LogLevelDebug);
}


@end
