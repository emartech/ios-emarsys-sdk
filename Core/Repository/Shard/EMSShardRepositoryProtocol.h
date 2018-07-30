//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSSQLSpecificationProtocol.h"
#import "EMSRepositoryProtocol.h"

@class EMSShard;

@protocol EMSShardRepositoryProtocol  <EMSRepositoryProtocol>

- (void)add:(EMSShard *)item;

- (void)remove:(id <EMSSQLSpecificationProtocol>)sqlSpecification;

- (NSArray<EMSShard *> *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification;

- (BOOL)isEmpty;

@end