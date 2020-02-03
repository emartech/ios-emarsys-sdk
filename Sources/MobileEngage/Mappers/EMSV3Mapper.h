//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRequestModelMapperProtocol.h"
#import "MERequestContext.h"

@class EMSEndpoint;

NS_ASSUME_NONNULL_BEGIN

@interface EMSV3Mapper : NSObject <EMSRequestModelMapperProtocol>

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext
                              endpoint:(EMSEndpoint *)endpoint;

@end

NS_ASSUME_NONNULL_END