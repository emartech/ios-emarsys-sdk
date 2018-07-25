//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogHandlerProtocol.h"

@interface MEIAMMetricsLogHandler : NSObject<EMSLogHandlerProtocol>

- (instancetype)initWithMetricsBuffer:(NSMutableDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *)metricsBuffer;

@end