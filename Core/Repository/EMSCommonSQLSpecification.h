//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSSQLSpecificationProtocol.h"

@interface EMSCommonSQLSpecification : NSObject <EMSSQLSpecificationProtocol>

- (NSString *)generateInStatementWithArgs:(NSArray<NSString *> *)args;

@end