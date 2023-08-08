//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PRERequestContext.h"
#import "EMSAbstractResponseHandler.h"

@class EMSEndpoint;

@interface EMSVisitorIdResponseHandler : EMSAbstractResponseHandler

@property(nonatomic, readonly) PRERequestContext *requestContext;
@property(nonatomic, readonly) EMSEndpoint *endpoint;

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext
                              endpoint:(EMSEndpoint *)endpoint;

@end