//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSPredictAggregateShardsTrigger.h"
#import "EMSRequestManager.h"
#import "EMSPredictMapper.h"
#import "EMSShardRepository.h"
#import "EMSFilterByValuesSpecification.h"
#import "EMSFilterByNothingSpecification.h"
#import "EMSSchemaContract.h"
#import "EMSShard.h"

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
            EMSFilterByValuesSpecification *specification = [[EMSFilterByValuesSpecification alloc] initWithValues:@[shards.firstObject.shardId]
                                                                                                            column:SHARD_COLUMN_NAME_SHARD_ID];
            [shardRepository remove:specification];
        }
    };
}


@end
