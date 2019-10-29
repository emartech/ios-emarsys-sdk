//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"

@class PRERequestContext;

@interface EMSXPResponseHandler : EMSAbstractResponseHandler

@property(nonatomic, readonly) PRERequestContext *requestContext;

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext;

@end