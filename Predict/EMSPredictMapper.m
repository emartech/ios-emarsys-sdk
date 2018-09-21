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
#import "PredictInternal.h"

@implementation EMSPredictMapper

- (instancetype)initWithRequestContext:(PRERequestContext *)requestContext {
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _requestContext = requestContext;
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
            [builder setUrl:[[NSURL urlWithBaseUrl:[NSString stringWithFormat:@"%@/merchants/%@", PREDICT_BASE_URL,
                                                                              self.requestContext.merchantId]
                                   queryParameters:queryParameters] absoluteString]];
            [builder setExpiry:[[NSDate dateWithTimeInterval:shard.ttl
                                                   sinceDate:shard.timestamp] timeIntervalSinceDate:[self.requestContext.timestampProvider provideTimestamp]]];
            [builder setMethod:HTTPMethodGET];
        }
                                                   timestampProvider:self.requestContext.timestampProvider
                                                        uuidProvider:self.requestContext.uuidProvider];
    return requestModel;
}

@end