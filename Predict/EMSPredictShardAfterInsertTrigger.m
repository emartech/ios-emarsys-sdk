//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSPredictShardAfterInsertTrigger.h"
#import "EMSSQLiteHelper.h"
#import "EMSRequestManager.h"
#import "EMSPredictMapper.h"
#import "EMSSchemaContract.h"
#import "EMSShardRepository.h"
#import "EMSShardQueryAllSpecification.h"
#import "EMSShardDeleteByIdsSpecification.h"

@implementation EMSPredictShardAfterInsertTrigger

- (instancetype)initWithSqliteHelper:(EMSSQLiteHelper *)sqliteHelper
                      requestManager:(EMSRequestManager *)requestManager
                              mapper:(EMSPredictMapper *)predictMapper
                          repository:(EMSShardRepository *)shardRepository {
    NSParameterAssert(sqliteHelper);
    NSParameterAssert(requestManager);
    NSParameterAssert(predictMapper);
    NSParameterAssert(shardRepository);
    if (self = [super init]) {
        _sqliteHelper = sqliteHelper;
        _requestManager = requestManager;
        _shardRepository = shardRepository;
        _predictMapper = predictMapper;
    }
    return self;
}

- (void)register {
    __weak typeof(self) weakSelf = self;
    [self.sqliteHelper registerTriggerWithTableName:SHARD_TABLE_NAME
                                    withTriggerType:EMSDBTriggerType.afterType
                                   withTriggerEvent:EMSDBTriggerEvent.insertEvent
                                    forTriggerBlock:^{
                                        NSArray<EMSShard *> *shards = [weakSelf.shardRepository query:[EMSShardQueryAllSpecification new]];
                                        if ([shards count] > 0) {
                                            EMSRequestModel *requestModel = [weakSelf.predictMapper requestFromShards:shards];
                                            [weakSelf.requestManager submitRequestModel:requestModel];
                                            [weakSelf.shardRepository remove:[[EMSShardDeleteByIdsSpecification alloc] initWithShards:@[shards.firstObject]]];
                                        }
                                    }];
}


@end