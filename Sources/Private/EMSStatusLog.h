//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogEntryProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSStatusLog : NSObject <EMSLogEntryProtocol>

- (instancetype)initWithClass:(Class)klass
                          sel:(SEL)sel
                   parameters:(nullable NSDictionary<NSString *, NSString *> *)parameters
                       status:(nullable NSDictionary<NSString *, NSString *> *)status;

@end

NS_ASSUME_NONNULL_END
