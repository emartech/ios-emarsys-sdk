//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSSQLSpecificationProtocol.h"

@interface EMSShardQueryAllSpecification : NSObject <EMSSQLSpecificationProtocol>
- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToSpecification:(EMSShardQueryAllSpecification *)specification;

- (NSUInteger)hash;
@end