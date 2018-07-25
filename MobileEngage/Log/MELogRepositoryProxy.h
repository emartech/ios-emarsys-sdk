//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogRepositoryProtocol.h"
#import "EMSLogHandlerProtocol.h"

@interface MELogRepositoryProxy: NSObject <EMSLogRepositoryProtocol>

- (instancetype)initWithLogRepository:(id<EMSLogRepositoryProtocol>)logRepository
                             handlers:(NSArray<id<EMSLogHandlerProtocol>> *)handlers;

@end