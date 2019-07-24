//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSPredictRequestModelBuilderProvider.h"
#import "EMSPredictRequestModelBuilder.h"
#import "PRERequestContext.h"

@interface EMSPredictRequestModelBuilderProvider()

@property(nonatomic, strong) PRERequestContext *requestContext;

@end

@implementation EMSPredictRequestModelBuilderProvider

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext {
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _requestContext = requestContext;
    }
    return self;
}

- (EMSPredictRequestModelBuilder *)provideBuilder {
    return [[EMSPredictRequestModelBuilder alloc] initWithContext:self.requestContext];
}

@end