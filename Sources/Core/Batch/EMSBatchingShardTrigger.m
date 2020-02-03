//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <ModelIO/ModelIO.h>
#import "EMSBatchingShardTrigger.h"
#import "EMSRequestManager.h"
#import "EMSRequestFromShardsMapperProtocol.h"
#import "EMSListChunker.h"
#import "EMSPredicate.h"
#import "EMSFilterByValuesSpecification.h"
#import "EMSShard.h"
#import "EMSSchemaContract.h"

@interface EMSBatchingShardTrigger ()

@property(nonatomic, strong) id <EMSShardRepositoryProtocol> shardRepository;
@property(nonatomic, strong) id <EMSSQLSpecificationProtocol> specification;
@property(nonatomic, strong) id <EMSRequestFromShardsMapperProtocol> mapper;
@property(nonatomic, strong) EMSListChunker *chunker;
@property(nonatomic, strong) EMSPredicate *predicate;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, assign) BOOL persistent;

@end

@implementation EMSBatchingShardTrigger

- (instancetype)initWithRepository:(id <EMSShardRepositoryProtocol>)shardRepository
                     specification:(id <EMSSQLSpecificationProtocol>)specification
                            mapper:(id <EMSRequestFromShardsMapperProtocol>)mapper
                           chunker:(EMSListChunker *)chunker
                         predicate:(EMSPredicate *)predicate
                    requestManager:(EMSRequestManager *)requestManager
                        persistent:(BOOL)persistent {
    NSParameterAssert(shardRepository);
    NSParameterAssert(specification);
    NSParameterAssert(mapper);
    NSParameterAssert(chunker);
    NSParameterAssert(predicate);
    NSParameterAssert(requestManager);
    if (self = [super init]) {
        _shardRepository = shardRepository;
        _specification = specification;
        _mapper = mapper;
        _chunker = chunker;
        _predicate = predicate;
        _requestManager = requestManager;
        _persistent = persistent;
    }
    return self;
}

- (void)trigger {
    NSArray<EMSShard *> *shards = [self.shardRepository query:self.specification];
    if ([self.predicate evaluate:shards]) {
        NSArray<NSArray<EMSShard *> *> *shardChunks = [self.chunker chunk:shards];
        for (NSArray<EMSShard *> *shardChunk in shardChunks) {
            EMSRequestModel *requestModel = [self.mapper requestFromShards:shardChunk];
            if (self.persistent) {
                [self.requestManager submitRequestModel:requestModel
                                    withCompletionBlock:nil];
            } else {
                [self.requestManager submitRequestModelNow:requestModel];
            }
            NSMutableArray *shardIds = [@[] mutableCopy];
            for (EMSShard *shard in shardChunk) {
                [shardIds addObject:shard.shardId];
            }
            [self.shardRepository remove:[[EMSFilterByValuesSpecification alloc] initWithValues:[NSArray arrayWithArray:shardIds]
                                                                                         column:SHARD_COLUMN_NAME_SHARD_ID]];
        }
    }
}

@end