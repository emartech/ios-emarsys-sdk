//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"
#import "MERequestContext.h"

static NSString *const CLIENT_STATE = @"X-Client-State";

@interface EMSClientStateResponseHandler : EMSAbstractResponseHandler

@property(nonatomic, readonly) MERequestContext *requestContext;

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext;

@end