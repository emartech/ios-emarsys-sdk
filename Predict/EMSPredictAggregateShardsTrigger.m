//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSPredictAggregateShardsTrigger.h"
#import "EMSRequestManager.h"
#import "EMSPredictMapper.h"
#import "EMSShardRepository.h"
#import "EMSShardQueryAllSpecification.h"
#import "EMSShardDeleteByIdsSpecification.h"

@implementation EMSPredictAggregateShardsTrigger

- (EMSTriggerBlock)createTriggerBlockWithRequestManager:(EMSRequestManager *)requestManager
                                                 mapper:(EMSPredictMapper *)predictMapper
                                             repository:(EMSShardRepository *)shardRepository {
    NSParameterAssert(requestManager);
    NSParameterAssert(predictMapper);
    NSParameterAssert(shardRepository);
    return ^{
        NSArray<EMSShard *> *shards = [shardRepository query:[EMSShardQueryAllSpecification new]];
        if ([shards count] > 0) {
            EMSRequestModel *requestModel = [predictMapper requestFromShards:shards];
            [requestManager submitRequestModel:requestModel];
            [shardRepository remove:[[EMSShardDeleteByIdsSpecification alloc] initWithShards:@[shards.firstObject]]];
        }
    };
}


@end