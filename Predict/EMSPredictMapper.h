//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRequestFromShardsMapperProtocol.h"

@class EMSUUIDProvider;
@class EMSTimestampProvider;
@class PRERequestContext;

@interface EMSPredictMapper : NSObject <EMSRequestFromShardsMapperProtocol>

@property(nonatomic, readonly) PRERequestContext *requestContext;

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext;

@end