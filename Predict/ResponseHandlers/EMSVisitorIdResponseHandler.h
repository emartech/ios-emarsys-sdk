//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PRERequestContext.h"
#import "EMSAbstractResponseHandler.h"

@interface EMSVisitorIdResponseHandler : EMSAbstractResponseHandler

@property(nonatomic, readonly) PRERequestContext *requestContext;

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext;

@end