//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRequestFromShardsMapperProtocol.h"

@class EMSUUIDProvider;
@class EMSTimestampProvider;
@class PRERequestContext;
@class EMSEndpoint;

@interface EMSPredictMapper : NSObject <EMSRequestFromShardsMapperProtocol>

@property(nonatomic, readonly) PRERequestContext *requestContext;
@property(nonatomic, readonly) EMSEndpoint *endpoint;

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext
                              endpoint:(EMSEndpoint *)endpoint;

@end