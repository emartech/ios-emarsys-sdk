//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSPredictMapper.h"
#import "EMSUUIDProvider.h"
#import "EMSTimestampProvider.h"
#import "EMSRequestModel.h"
#import "PRERequestContext.h"
#import "NSURL+EMSCore.h"
#import "EMSShard.h"
#import "EMSPredictInternal.h"
#import "EMSDeviceInfo.h"
#import "EMSEndpoint.h"

@implementation EMSPredictMapper

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

- (EMSRequestModel *)requestFromShards:(NSArray<EMSShard *> *)shards {
    NSParameterAssert(shards);
    NSParameterAssert([shards count] > 0);

    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            EMSShard *shard = shards.firstObject;
            NSMutableDictionary<NSString *, NSString *> *queryParameters = [NSMutableDictionary new];
            queryParameters[@"cp"] = @"1";
            queryParameters[@"ci"] = self.requestContext.customerId;
            queryParameters[@"vi"] = self.requestContext.visitorId;
            [queryParameters addEntriesFromDictionary:shard.data];
            [builder setUrl:[[NSURL urlWithBaseUrl:[NSString stringWithFormat:@"%@/merchants/%@",
                                                                              [self.endpoint predictUrl],
                                                                              self.requestContext.merchantId]
                                   queryParameters:queryParameters] absoluteString]];
            [builder setExpiry:[[NSDate dateWithTimeInterval:shard.ttl
                                                   sinceDate:shard.timestamp] timeIntervalSinceDate:[self.requestContext.timestampProvider provideTimestamp]]];
            [builder setMethod:HTTPMethodGET];
            [builder setHeaders:@{@"User-Agent": [NSString stringWithFormat:@"EmarsysSDK|osversion:%@|platform:%@",
                                                                            self.requestContext.deviceInfo.osVersion,
                                                                            self.requestContext.deviceInfo.systemName]}];
        }
                                                   timestampProvider:self.requestContext.timestampProvider
                                                        uuidProvider:self.requestContext.uuidProvider];
    return requestModel;
}

@end