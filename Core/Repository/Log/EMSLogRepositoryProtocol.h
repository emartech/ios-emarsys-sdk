//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRepositoryProtocol.h"

@protocol EMSLogRepositoryProtocol <EMSRepositoryProtocol>

- (void)add:(NSDictionary<NSString *, id> *)item;

- (void)remove:(id <EMSSQLSpecificationProtocol>)sqlSpecification;

- (NSArray<NSDictionary<NSString *, id> *> *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification;

- (BOOL)isEmpty;

@end