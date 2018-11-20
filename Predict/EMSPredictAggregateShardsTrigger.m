//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSPredictAggregateShardsTrigger.h"
#import "EMSRequestManager.h"
#import "EMSPredictMapper.h"
#import "EMSShardRepository.h"
#import "EMSShardDeleteByIdsSpecification.h"
#import "EMSFilterByNothingSpecification.h"

@implementation EMSPredictAggregateShardsTrigger

- (EMSTriggerBlock)createTriggerBlockWithRequestManager:(EMSRequestManager *)requestManager
                                                 mapper:(EMSPredictMapper *)predictMapper
                                             repository:(EMSShardRepository *)shardRepository {
    NSParameterAssert(requestManager);
    NSParameterAssert(predictMapper);
    NSParameterAssert(shardRepository);
    return ^{
        NSArray<EMSShard *> *shards = [shardRepository query:[EMSFilterByNothingSpecification new]];
        if ([shards count] > 0) {
            EMSRequestModel *requestModel = [predictMapper requestFromShards:shards];
            [requestManager submitRequestModel:requestModel withCompletionBlock:nil];
            [shardRepository remove:[[EMSShardDeleteByIdsSpecification alloc] initWithShards:@[shards.firstObject]]];
        }
    };
}


@end