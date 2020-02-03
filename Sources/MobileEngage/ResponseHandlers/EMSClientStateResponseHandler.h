//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"
#import "MERequestContext.h"

@class EMSEndpoint;

static NSString *const CLIENT_STATE = @"X-Client-State";

@interface EMSClientStateResponseHandler : EMSAbstractResponseHandler

@property(nonatomic, readonly) MERequestContext *requestContext;
@property(nonatomic, readonly) EMSEndpoint *endpoint;

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext
                              endpoint:(EMSEndpoint *)endpoint;

@end