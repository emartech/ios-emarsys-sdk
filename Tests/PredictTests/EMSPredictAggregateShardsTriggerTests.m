//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSPredictAggregateShardsTrigger.h"
#import "EMSRequestManager.h"
#import "EMSPredictMapper.h"
#import "EMSSQLiteHelper.h"
#import "EMSShardRepository.h"
#import "EMSShard.h"
#import "EMSShardQueryAllSpecification.h"
#import "EMSShardDeleteByIdsSpecification.h"

SPEC_BEGIN(EMSPredictAggregateShardsTriggerTests)

        __block EMSSQLiteHelper *sqliteHelper;
        __block EMSRequestManager *requestManager;
        __block EMSPredictMapper *predictMapper;
        __block EMSShardRepository *shardRepository;


        beforeEach(^{
            sqliteHelper = [EMSSQLiteHelper mock];
            requestManager = [EMSRequestManager mock];
            predictMapper = [EMSPredictMapper mock];
            shardRepository = [EMSShardRepository mock];
        });

        describe(@"initWithSqliteHelper:requestManager:predictMapper:repository:", ^{

            it(@"should throw exception when requestManager is nil", ^{
                @try {
                    [[EMSPredictAggregateShardsTrigger new] createTriggerBlockWithRequestManager:nil mapper:predictMapper repository:shardRepository];
                    fail(@"Expected Exception when requestManager is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestManager"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when predictMapper is nil", ^{
                @try {
                    [[EMSPredictAggregateShardsTrigger new] createTriggerBlockWithRequestManager:requestManager
                                                                                          mapper:nil
                                                                                      repository:shardRepository];
                    fail(@"Expected Exception when predictMapper is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: predictMapper"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when shardRepository is nil", ^{
                @try {
                    [[EMSPredictAggregateShardsTrigger new] createTriggerBlockWithRequestManager:requestManager
                                                                                          mapper:predictMapper
                                                                                      repository:nil];
                    fail(@"Expected Exception when shardRepository is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: shardRepository"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

        });

        describe(@"trigger action", ^{


            it(@"should query the shard and send it as a requestModel", ^{
                EMSTriggerBlock triggerBlock = [[EMSPredictAggregateShardsTrigger new] createTriggerBlockWithRequestManager:requestManager
                                                                                                                     mapper:predictMapper
                                                                                                                 repository:shardRepository];

                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id"
                                                               type:@"type"
                                                               data:@{@"x": @"y"}
                                                          timestamp:[NSDate date]
                                                                ttl:5000];
                EMSRequestModel *requestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                                 timestamp:[NSDate date]
                                                                                    expiry:42.0
                                                                                       url:[NSURL URLWithString:@"https://www.emarsys.com"]
                                                                                    method:@"GET"
                                                                                   payload:nil
                                                                                   headers:nil
                                                                                    extras:nil];

                NSArray *const shards = @[shard];
                EMSShardQueryAllSpecification *specification = [EMSShardQueryAllSpecification new];
                EMSShardDeleteByIdsSpecification *deleteByIdsSpecification = [[EMSShardDeleteByIdsSpecification alloc] initWithShards:shards];
                [[shardRepository should] receive:@selector(query:) andReturn:shards withArguments:specification];
                [[predictMapper should] receive:@selector(requestFromShards:) andReturn:requestModel withArguments:shards];
                [[requestManager should] receive:@selector(submitRequestModel:) withArguments:requestModel];
                [[shardRepository should] receive:@selector(remove:) withArguments:deleteByIdsSpecification];

                triggerBlock();
            });

            it(@"should not map, submit or delete when returned shards array is nil", ^{
                EMSTriggerBlock triggerBlock = [[EMSPredictAggregateShardsTrigger new] createTriggerBlockWithRequestManager:requestManager
                                                                                                                     mapper:predictMapper
                                                                                                                 repository:shardRepository];

                EMSRequestModel *requestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                                 timestamp:[NSDate date]
                                                                                    expiry:42.0
                                                                                       url:[NSURL URLWithString:@"https://www.emarsys.com"]
                                                                                    method:@"GET"
                                                                                   payload:nil
                                                                                   headers:nil
                                                                                    extras:nil];

                NSArray *const shards = @[];
                EMSShardQueryAllSpecification *specification = [EMSShardQueryAllSpecification new];
                EMSShardDeleteByIdsSpecification *deleteByIdsSpecification = [[EMSShardDeleteByIdsSpecification alloc] initWithShards:shards];
                [[shardRepository should] receive:@selector(query:) andReturn:shards withArguments:specification];
                [[predictMapper shouldNot] receive:@selector(requestFromShards:) andReturn:requestModel withArguments:shards];
                [[requestManager shouldNot] receive:@selector(submitRequestModel:) withArguments:requestModel];
                [[shardRepository shouldNot] receive:@selector(remove:) withArguments:deleteByIdsSpecification];

                triggerBlock();
            });

        });

SPEC_END
