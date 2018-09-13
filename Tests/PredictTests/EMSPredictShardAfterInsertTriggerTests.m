//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSPredictShardAfterInsertTrigger.h"
#import "EMSRequestManager.h"
#import "EMSPredictMapper.h"
#import "EMSSQLiteHelper.h"
#import "EMSShardRepository.h"
#import "EMSShard.h"
#import "EMSShardQueryAllSpecification.h"
#import "EMSShardDeleteByIdsSpecification.h"

SPEC_BEGIN(EMSPredictShardAfterInsertTriggerTests)

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

            it(@"should throw exception when sqliteHelper is nil", ^{
                @try {
                    [[EMSPredictShardAfterInsertTrigger alloc] initWithSqliteHelper:nil
                                                                     requestManager:requestManager
                                                                             mapper:predictMapper
                                                                         repository:shardRepository];
                    fail(@"Expected Exception when sqliteHelper is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: sqliteHelper"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when requestManager is nil", ^{
                @try {
                    [[EMSPredictShardAfterInsertTrigger alloc] initWithSqliteHelper:sqliteHelper
                                                                     requestManager:nil
                                                                             mapper:predictMapper
                                                                         repository:shardRepository];
                    fail(@"Expected Exception when requestManager is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestManager"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when predictMapper is nil", ^{
                @try {
                    [[EMSPredictShardAfterInsertTrigger alloc] initWithSqliteHelper:sqliteHelper
                                                                     requestManager:requestManager
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
                    [[EMSPredictShardAfterInsertTrigger alloc] initWithSqliteHelper:sqliteHelper
                                                                     requestManager:requestManager
                                                                             mapper:predictMapper
                                                                         repository:nil];
                    fail(@"Expected Exception when shardRepository is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: shardRepository"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

        });

        describe(@"register", ^{

            it(@"should call register on sqliteHelper", ^{
                EMSSQLiteHelper *helper = sqliteHelper;
                EMSPredictShardAfterInsertTrigger *trigger = [[EMSPredictShardAfterInsertTrigger alloc] initWithSqliteHelper:helper
                                                                                                              requestManager:requestManager
                                                                                                                      mapper:predictMapper
                                                                                                                  repository:shardRepository];

                [[helper should] receive:@selector(registerTriggerWithTableName:withTriggerType:withTriggerEvent:forTriggerBlock:)
                           withArguments:@"shard",
                                         [EMSDBTriggerType afterType],
                                         [EMSDBTriggerEvent insertEvent], kw_any()];

                [trigger register];
            });

            it(@"should handle trigger well", ^{
                EMSPredictShardAfterInsertTrigger *trigger = [[EMSPredictShardAfterInsertTrigger alloc] initWithSqliteHelper:sqliteHelper
                                                                                                              requestManager:requestManager
                                                                                                                      mapper:predictMapper
                                                                                                                  repository:shardRepository];

                KWCaptureSpy *triggerSpy = [sqliteHelper captureArgument:@selector(registerTriggerWithTableName:withTriggerType:withTriggerEvent:forTriggerBlock:)
                                                                 atIndex:3];

                [trigger register];
                EMSTriggerBlock block = triggerSpy.argument;

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

                block();
            });

            it(@"should not map, submit or delete when returned shards array is nil", ^{
                EMSPredictShardAfterInsertTrigger *trigger = [[EMSPredictShardAfterInsertTrigger alloc] initWithSqliteHelper:sqliteHelper
                                                                                                              requestManager:requestManager
                                                                                                                      mapper:predictMapper
                                                                                                                  repository:shardRepository];

                KWCaptureSpy *triggerSpy = [sqliteHelper captureArgument:@selector(registerTriggerWithTableName:withTriggerType:withTriggerEvent:forTriggerBlock:)
                                                                 atIndex:3];

                [trigger register];
                EMSTriggerBlock block = triggerSpy.argument;
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

                block();
            });

        });

SPEC_END
