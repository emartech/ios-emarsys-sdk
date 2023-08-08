//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSSQLSpecificationProtocol.h"

@protocol EMSRepositoryProtocol <NSObject>

- (void)add:(id)item;

- (void)remove:(id <EMSSQLSpecificationProtocol>)sqlSpecification;

- (NSArray *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification;

@end