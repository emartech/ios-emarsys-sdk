//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestModelMapperProtocol.h"

@class EMSEndpoint;
@class MERequestContext;

@interface EMSOpenIdTokenMapper: NSObject <EMSRequestModelMapperProtocol>

@property(nonatomic, readonly) MERequestContext *requestContext;
@property(nonatomic, readonly) EMSEndpoint *endpoint;

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext
                              endpoint:(EMSEndpoint *)endpoint;

@end