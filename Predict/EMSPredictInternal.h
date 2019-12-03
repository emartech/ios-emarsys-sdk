//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSPredictProtocol.h"
#import "EMSPredictInternalProtocol.h"

@class PRERequestContext;
@class EMSRequestManager;
@class EMSPredictRequestModelBuilderProvider;
@class EMSProductMapper;

@interface EMSPredictInternal : NSObject <EMSPredictProtocol, EMSPredictInternalProtocol>

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext
                        requestManager:(EMSRequestManager *)requestManager
                requestBuilderProvider:(EMSPredictRequestModelBuilderProvider *)requestBuilderProvider
                         productMapper:(EMSProductMapper *)productMapper;

@end