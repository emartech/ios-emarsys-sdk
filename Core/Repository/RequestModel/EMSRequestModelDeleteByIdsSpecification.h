//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSSQLSpecificationProtocol.h"
#import "EMSRequestModel.h"

@interface EMSRequestModelDeleteByIdsSpecification : NSObject <EMSSQLSpecificationProtocol>

@property(nonatomic, readonly) EMSRequestModel *requestModel;

- (instancetype)initWithRequestModel:(EMSRequestModel *)requestModel;

@end