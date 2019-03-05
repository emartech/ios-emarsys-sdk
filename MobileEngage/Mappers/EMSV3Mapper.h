//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRequestModelMapperProtocol.h"
#import "MERequestContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSV3Mapper : NSObject <EMSRequestModelMapperProtocol>

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext;

@end

NS_ASSUME_NONNULL_END