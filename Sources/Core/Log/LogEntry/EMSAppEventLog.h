//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogEntryProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSAppEventLog : NSObject <EMSLogEntryProtocol>

- (instancetype)initWithEventName:(NSString *)eventName
                       attributes:(nullable NSDictionary<NSString *, id> *)attributes;

@end

NS_ASSUME_NONNULL_END