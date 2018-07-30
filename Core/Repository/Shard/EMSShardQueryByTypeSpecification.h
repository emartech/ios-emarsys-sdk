//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSSQLSpecificationProtocol.h"

@interface EMSShardQueryByTypeSpecification : NSObject <EMSSQLSpecificationProtocol>

- (instancetype)initWithType:(NSString *)type;

@end