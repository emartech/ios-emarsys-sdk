//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSRepositoryProtocol.h"
#import "EMSRequestModel.h"
#import "EMSSQLSpecificationProtocol.h"

@protocol EMSRequestModelRepositoryProtocol <EMSRepositoryProtocol>

- (void)add:(EMSRequestModel *)item;

- (void)remove:(id <EMSSQLSpecificationProtocol>)sqlSpecification;

- (NSArray<EMSRequestModel *> *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification;

- (BOOL)isEmpty;

@end