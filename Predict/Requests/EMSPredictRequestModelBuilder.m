//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSPredictRequestModelBuilder.h"
#import "PRERequestContext.h"
#import "EMSRequestModel.h"
#import "EMSDeviceInfo.h"
#import "EMSLogic.h"

@interface EMSPredictRequestModelBuilder ()

@property(nonatomic, strong) PRERequestContext *requestContext;
@property(nonatomic, strong) EMSLogic *logic;

@end


@implementation EMSPredictRequestModelBuilder

- (instancetype)initWithContext:(PRERequestContext *)requestContext {
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _requestContext = requestContext;
    }
    return self;
}

- (instancetype)addLogic:(EMSLogic *)logic {
    _logic = logic;
    return self;
}


- (EMSRequestModel *)build {
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                if (self.logic) {
                    [builder setUrl:[NSString stringWithFormat:@"https://recommender.scarabresearch.com/merchants/%@/", self.requestContext.merchantId]
                    queryParameters:@{
                            @"f": [NSString stringWithFormat:@"f:%@,l:2,o:0", self.logic.logic],
                            @"q": self.logic.data[@"q"]
                    }];
                } else {
                    [builder setUrl:[NSString stringWithFormat:@"https://recommender.scarabresearch.com/merchants/%@/", self.requestContext.merchantId]];
                }

                [builder setMethod:HTTPMethodGET];
                [builder setHeaders:@{@"User-Agent": [NSString stringWithFormat:@"EmarsysSDK|osversion:%@|platform:%@",
                                                                                self.requestContext.deviceInfo.osVersion,
                                                                                self.requestContext.deviceInfo.systemName]}];
            }                                      timestampProvider:self.requestContext.timestampProvider
                                                        uuidProvider:self.requestContext.uuidProvider];
    return requestModel;
}


@end