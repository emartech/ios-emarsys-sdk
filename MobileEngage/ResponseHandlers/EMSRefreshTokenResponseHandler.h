//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"

@class MERequestContext;

@interface EMSRefreshTokenResponseHandler : EMSAbstractResponseHandler

@property(nonatomic, readonly) MERequestContext *requestContext;

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext;

@end