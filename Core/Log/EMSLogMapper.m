//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSLogMapper.h"
#import "EMSRequestModel.h"
#import "EMSShard.h"

@interface EMSLogMapper ()
@property(nonatomic, strong) MERequestContext *requestContext;
@end

@implementation EMSLogMapper

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext {
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _requestContext = requestContext;
    }
    return self;
}

- (EMSRequestModel *)requestFromShards:(NSArray<EMSShard *> *)shards {
    NSParameterAssert(shards);
    NSParameterAssert([shards count] > 0);
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            NSMutableArray<NSDictionary<NSString *, id> *> *logs = [NSMutableArray new];
            for (EMSShard *shard in shards) {
                NSMutableDictionary<NSString *, id> *shardData = [NSMutableDictionary dictionaryWithDictionary:shard.data];
                shardData[@"type"] = shard.type;
                [logs addObject:[NSDictionary dictionaryWithDictionary:shardData]];
            }
            [builder setUrl:@"https://ems-log-dealer.herokuapp.com/log"];
            [builder setMethod:HTTPMethodPOST];
            [builder setPayload:@{@"logs": [NSArray arrayWithArray:logs]}];
        }
                          timestampProvider:self.requestContext.timestampProvider
                               uuidProvider:self.requestContext.uuidProvider];
}

@end