//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSBatchingShardTriggerFactory.h"
#import "EMSRequestManager.h"
#import "EMSRequestFromShardsMapperProtocol.h"
#import "EMSListChunker.h"
#import "EMSPredicateProtocol.h"
#import "EMSFilterByValuesSpecification.h"
#import "EMSShard.h"
#import "EMSSchemaContract.h"

@implementation EMSBatchingShardTriggerFactory

- (EMSTriggerBlock)createTriggerBlockWithRepository:(id <EMSShardRepositoryProtocol>)shardRepository
                                      specification:(id <EMSSQLSpecificationProtocol>)specification
                                             mapper:(id <EMSRequestFromShardsMapperProtocol>)mapper
                                            chunker:(EMSListChunker *)chunker
                                          predicate:(id <EMSPredicateProtocol>)predicate
                                     requestManager:(EMSRequestManager *)requestManager {
    return ^{
        NSArray<EMSShard *> *shards = [shardRepository query:specification];
        if ([predicate evaluate:shards]) {
            NSArray<NSArray<EMSShard *> *> *shardChunks = [chunker chunk:shards];
            for (NSArray<EMSShard *> *shardChunk in shardChunks) {
                EMSRequestModel *requestModel = [mapper requestFromShards:shardChunk];
                [requestManager submitRequestModel:requestModel
                               withCompletionBlock:nil];
                NSMutableArray *shardIds = [@[] mutableCopy];
                for (EMSShard *shard in shardChunk) {
                    [shardIds addObject:shard.shardId];
                }
                [shardRepository remove:[[EMSFilterByValuesSpecification alloc] initWithValues:[NSArray arrayWithArray:shardIds]
                                                                                        column:SHARD_COLUMN_NAME_SHARD_ID]];
            }
        }
    };
}


@end