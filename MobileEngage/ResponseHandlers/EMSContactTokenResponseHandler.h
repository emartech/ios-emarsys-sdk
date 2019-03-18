//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"

@class MERequestContext;

@interface EMSContactTokenResponseHandler : EMSAbstractResponseHandler

@property(nonatomic, readonly) MERequestContext *requestContext;

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext;

@end