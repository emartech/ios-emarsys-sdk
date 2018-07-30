//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSSQLSpecificationProtocol.h"

@class EMSShard;

@interface EMSShardDeleteByIdsSpecification : NSObject <EMSSQLSpecificationProtocol>

- (instancetype)initWithShards:(NSArray<EMSShard *> *)shards;

@end