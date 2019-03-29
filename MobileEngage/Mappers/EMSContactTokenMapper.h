//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRequestModelMapperProtocol.h"

@class MERequestContext;

@interface EMSContactTokenMapper : NSObject <EMSRequestModelMapperProtocol>

@property(nonatomic, readonly) MERequestContext *requestContext;

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext;

@end