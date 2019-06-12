//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogEntryProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSMethodNotAllowed : NSObject <EMSLogEntryProtocol>

- (instancetype)initWithClass:(Class)klass
                   methodName:(NSString *)methodName
                   parameters:(nullable NSDictionary<NSString *, id> *)parameters;

@end

NS_ASSUME_NONNULL_END