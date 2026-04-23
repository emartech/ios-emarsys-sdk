//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRequestModelMapperProtocol.h"
#import "PRERequestContext.h"

@class EMSEndpoint;

@interface EMSMerchantIdMapper : NSObject <EMSRequestModelMapperProtocol>

@property(nonatomic, readonly) PRERequestContext *requestContext;
@property(nonatomic, readonly) EMSEndpoint *endpoint;

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext
                              endpoint:(EMSEndpoint *)endpoint;

@end
