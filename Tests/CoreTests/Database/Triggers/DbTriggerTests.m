//
//  Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSSQLiteHelper.h"
#import "EMSSqliteQueueSchemaHandler.h"
#import "EMSSchemaContract.h"
#import "EMSRequestModelMapper.h"
#import "EMSShard.h"
#import "EMSShardMapper.h"
#import "KWBeZeroMatcher.h"
#import "KWEqualMatcher.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]
#define TEST_SHARD_SELECT_ALL @"SELECT * FROM shard ORDER BY ROWID ASC;"

SPEC_BEGIN(DBTriggerTests)

        __block EMSSQLiteHelper *dbHelper;
        __block EMSSqliteQueueSchemaHandler *schemaHandler;

        beforeEach(^{
            [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                       error:nil];
            schemaHandler = [[EMSSqliteQueueSchemaHandler alloc] init];
            dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                      schemaDelegate:schemaHandler];
        });

        afterEach(^{
            [dbHelper close];
        });


        void (^runCommandOnTestDB)(NSString *sql) = ^(NSString *sql) {
            sqlite3 *db;
            sqlite3_open([TEST_DB_PATH UTF8String], &db);
            sqlite3_stmt *statement;
            sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil);
            sqlite3_step(statement);
            sqlite3_close(db);
        };


        describe(@"registerTriggerWithTableName:withTriggerType:withTriggerEvent:forTriggerBlock:", ^{

            it(@"should run afterInsert trigger when inserting something in the given table", ^{
                [dbHelper open];
                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:30];

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];
                [dbHelper registerTriggerWithTableName:@"shard"
                                       withTriggerType:[EMSDBTriggerType afterType]
                                      withTriggerEvent:[EMSDBTriggerEvent insertEvent]
                                       forTriggerBlock:^{
                                           [expectation fulfill];
                                       }];
                [dbHelper insertModel:shard
                               mapper:[EMSShardMapper new]];

                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:2];
                [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
            });

            it(@"should run all afterInsert trigger when inserting something in the given table", ^{
                [dbHelper open];
                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:30];

                XCTestExpectation *expectation1 = [[XCTestExpectation alloc] initWithDescription:@"expectation1"];
                XCTestExpectation *expectation2 = [[XCTestExpectation alloc] initWithDescription:@"expectation2"];
                XCTestExpectation *expectation3 = [[XCTestExpectation alloc] initWithDescription:@"expectation3"];

                [dbHelper registerTriggerWithTableName:@"shard"
                                       withTriggerType:[EMSDBTriggerType afterType]
                                      withTriggerEvent:[EMSDBTriggerEvent insertEvent]
                                       forTriggerBlock:^{
                                           [expectation1 fulfill];
                                       }];
                [dbHelper registerTriggerWithTableName:@"shard"
                                       withTriggerType:[EMSDBTriggerType afterType]
                                      withTriggerEvent:[EMSDBTriggerEvent insertEvent]
                                       forTriggerBlock:^{
                                           [expectation2 fulfill];
                                       }];
                [dbHelper registerTriggerWithTableName:@"shard"
                                       withTriggerType:[EMSDBTriggerType afterType]
                                      withTriggerEvent:[EMSDBTriggerEvent insertEvent]
                                       forTriggerBlock:^{
                                           [expectation3 fulfill];
                                       }];

                [dbHelper insertModel:shard
                               mapper:[EMSShardMapper new]];

                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation1, expectation2, expectation3] timeout:2 enforceOrder:YES];
                [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
            });

            it(@"should run afterInsert trigger after inserting something in the given table", ^{
                [dbHelper open];
                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:30];

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];
                [dbHelper registerTriggerWithTableName:@"shard"
                                       withTriggerType:[EMSDBTriggerType afterType]
                                      withTriggerEvent:[EMSDBTriggerEvent insertEvent]
                                       forTriggerBlock:^{
                                           [expectation fulfill];
                                           NSArray *shards = [dbHelper executeQuery:TEST_SHARD_SELECT_ALL
                                                                             mapper:[EMSShardMapper new]];
                                           EMSShard *expectedShard = [shards lastObject];
                                           [[shard should] equal:expectedShard];
                                           [[theValue([shards count]) should] equal:theValue(1)];
                                       }];

                [dbHelper insertModel:shard
                               mapper:[EMSShardMapper new]];

                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:2];
                [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
            });

            it(@"should run beforeInsert trigger when inserting something in the given table", ^{
                [dbHelper open];
                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:30];

                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];
                [dbHelper registerTriggerWithTableName:@"shard"
                                       withTriggerType:[EMSDBTriggerType beforeType]
                                      withTriggerEvent:[EMSDBTriggerEvent insertEvent]
                                       forTriggerBlock:^{
                                           [expectation fulfill];
                                       }];
                [dbHelper insertModel:shard
                               mapper:[EMSShardMapper new]];

                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:2];
                [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
            });

        });

        describe(@"Database trigger tests", ^{
            const EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:30];

            __block EMSDBTriggerType *type;
            __block EMSDBTriggerEvent *event;
            __block NSNumber *expectedItemCount;
            __block XCTestExpectation *expectation;

            __block void (^setupBlock)();
            __block EMSTriggerBlock triggerBlock;
            __block void (^actionBlock)();

            beforeEach(^{
                [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                           error:nil];
                schemaHandler = [[EMSSqliteQueueSchemaHandler alloc] init];
                dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                          schemaDelegate:schemaHandler];
                [dbHelper open];
                expectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];
            });

            afterEach(^{
                [dbHelper close];
            });

            __block NSArray *testDataSet = @[
                    @[
                            [EMSDBTriggerType beforeType],
                            [EMSDBTriggerEvent insertEvent],
                            ^{
                            },
                            ^{
                                [expectation fulfill];
                                NSArray *shards = [dbHelper executeQuery:SQL_SHARD_SELECTALL
                                                                  mapper:[EMSShardMapper new]];
                                [[theValue([shards count]) should] beZero];
                            },
                            ^{
                                [dbHelper insertModel:shard
                                               mapper:[EMSShardMapper new]];
                            }
                    ],
                    @[
                            [EMSDBTriggerType afterType],
                            [EMSDBTriggerEvent insertEvent],
                            ^{
                            },
                            ^{
                                [expectation fulfill];
                                NSArray *shards = [dbHelper executeQuery:SQL_SHARD_SELECTALL
                                                                  mapper:[EMSShardMapper new]];
                                [[theValue([shards count]) should] equal:theValue(1)];
                            },
                            ^{
                                [dbHelper insertModel:shard
                                               mapper:[EMSShardMapper new]];
                            }
                    ]

            ];


            for (NSArray *parameters in testDataSet) {
                type = parameters[0];
                event = parameters[1];
                setupBlock = parameters[2];
                triggerBlock = parameters[3];
                actionBlock = parameters[4];

                it([NSString stringWithFormat:@"should call the trigger action for %@ %@", type, event], ^{
                    setupBlock();
                    [dbHelper registerTriggerWithTableName:@"shard"
                                           withTriggerType:type
                                          withTriggerEvent:event
                                           forTriggerBlock:triggerBlock];
                    actionBlock();


                    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:2 enforceOrder:YES];
                    [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
                });
            }

        });


SPEC_END
