//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSPredictRequestModelBuilder;
@class PRERequestContext;
@class EMSEndpoint;


@interface EMSPredictRequestModelBuilderProvider : NSObject

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext
                              endpoint:(EMSEndpoint *)endpoint;

- (EMSPredictRequestModelBuilder *)provideBuilder;
@end