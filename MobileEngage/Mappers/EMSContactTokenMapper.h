//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRequestModelMapperProtocol.h"

@class MERequestContext;
@class EMSEndpoint;

@interface EMSContactTokenMapper : NSObject <EMSRequestModelMapperProtocol>

@property(nonatomic, readonly) MERequestContext *requestContext;
@property(nonatomic, readonly) EMSEndpoint *endpoint;

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext
                              endpoint:(EMSEndpoint *)endpoint;

@end