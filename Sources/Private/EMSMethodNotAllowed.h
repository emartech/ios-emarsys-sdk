//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogEntryProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSMethodNotAllowed : NSObject <EMSLogEntryProtocol>

- (instancetype)initWithClass:(Class)klass
                          sel:(SEL)sel
                   parameters:(nullable NSDictionary<NSString *, NSString *> *)parameters;

- (instancetype)initWithProtocol:(Protocol *)proto
                             sel:(SEL)sel
                      parameters:(nullable NSDictionary<NSString *, NSString *> *)parameters;

@end

NS_ASSUME_NONNULL_END
