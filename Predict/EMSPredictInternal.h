//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSPredictProtocol.h"
#import "EMSPredictInternalProtocol.h"

@class PRERequestContext;
@class EMSRequestManager;

#define PREDICT_BASE_URL @"https://recommender.scarabresearch.com"

@interface EMSPredictInternal : NSObject <EMSPredictProtocol, EMSPredictInternalProtocol>

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext
                        requestManager:(EMSRequestManager *)requestManager;


@end