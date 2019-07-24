//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSPredictRequestModelBuilder;
@class PRERequestContext;


@interface EMSPredictRequestModelBuilderProvider : NSObject

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext;

- (EMSPredictRequestModelBuilder *)provideBuilder;
@end