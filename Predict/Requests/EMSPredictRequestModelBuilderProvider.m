//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSPredictRequestModelBuilderProvider.h"
#import "EMSPredictRequestModelBuilder.h"
#import "PRERequestContext.h"
#import "EMSEndpoint.h"

@interface EMSPredictRequestModelBuilderProvider ()

@property(nonatomic, strong) PRERequestContext *requestContext;
@property(nonatomic, strong) EMSEndpoint *endpoint;

@end

@implementation EMSPredictRequestModelBuilderProvider

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext
                              endpoint:(EMSEndpoint *)endpoint {
    NSParameterAssert(requestContext);
    NSParameterAssert(endpoint);
    if (self = [super init]) {
        _requestContext = requestContext;
        _endpoint = endpoint;
    }
    return self;
}

- (EMSPredictRequestModelBuilder *)provideBuilder {
    return [[EMSPredictRequestModelBuilder alloc] initWithContext:self.requestContext
                                                         endpoint:self.endpoint];
}

@end