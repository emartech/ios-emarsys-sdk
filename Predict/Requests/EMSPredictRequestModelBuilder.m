//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSPredictRequestModelBuilder.h"
#import "PRERequestContext.h"
#import "EMSRequestModel.h"
#import "EMSDeviceInfo.h"

@interface EMSPredictRequestModelBuilder ()

@property(nonatomic, strong) PRERequestContext *requestContext;
@property(nonatomic, strong) NSString *searchTerm;

@end


@implementation EMSPredictRequestModelBuilder

- (instancetype)initWithContext:(PRERequestContext *)requestContext {
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _requestContext = requestContext;
    }
    return self;
}

- (instancetype)addSearchTerm:(NSString *)searchTerm {
    _searchTerm = searchTerm;
    return self;
}


- (EMSRequestModel *)build {
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                if (_searchTerm) {
                    [builder setUrl:[NSString stringWithFormat:@"https://recommender.scarabresearch.com/merchants/%@/", self.requestContext.merchantId]
                    queryParameters:@{@"f": @"f:SEARCH,l:2,o:0",
                                    @"q": self.searchTerm}];
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