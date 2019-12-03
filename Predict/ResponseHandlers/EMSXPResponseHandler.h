//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"

@class PRERequestContext;
@class EMSEndpoint;

@interface EMSXPResponseHandler : EMSAbstractResponseHandler

@property(nonatomic, readonly) PRERequestContext *requestContext;
@property(nonatomic, readonly) EMSEndpoint *endpoint;

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext
                              endpoint:(EMSEndpoint *)endpoint;

@end