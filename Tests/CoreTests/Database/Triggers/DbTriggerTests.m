//
//  Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSSQLiteHelper.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSSchemaContract.h"
#import "EMSRequestModelMapper.h"
#import "EMSShard.h"
#import "EMSShardMapper.h"
#import "EMSDBTriggerKey.h"
#import "FakeDBTrigger.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]
#define TEST_SHARD_SELECT_ALL @"SELECT * FROM shard ORDER BY ROWID ASC;"

SPEC_BEGIN(DBTriggerTests)

        __block EMSSQLiteHelper *dbHelper;
        __block EMSSqliteSchemaHandler *schemaHandler;
        __block XCTestExpectation *defaultExpectation;
        __block id <EMSDBTriggerProtocol> dbTrigger;

        beforeEach(^{
            [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                       error:nil];
            schemaHandler = [[EMSSqliteSchemaHandler alloc] init];
            dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                      schemaDelegate:schemaHandler];

            defaultExpectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];
            dbTrigger = [[FakeDBTrigger alloc] initWithExpectation:defaultExpectation];
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


        describe(@"registerTriggerWithTableName:triggerType:triggerEvent:trigger:", ^{

            it(@"should run afterInsert trigger when inserting something in the given table", ^{
                [dbHelper open];
                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id"
                                                               type:@"type"
                                                               data:@{}
                                                          timestamp:[NSDate date]
                                                                ttl:30];

                [dbHelper registerTriggerWithTableName:@"shard"
                                           triggerType:[EMSDBTriggerType afterType]
                                          triggerEvent:[EMSDBTriggerEvent insertEvent]
                                               trigger:dbTrigger];
                [dbHelper insertModel:shard
                               mapper:[EMSShardMapper new]];

                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[defaultExpectation] timeout:2];
                [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
            });

            it(@"should run all afterInsert trigger when inserting something in the given table", ^{
                [dbHelper open];
                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id"
                                                               type:@"type"
                                                               data:@{}
                                                          timestamp:[NSDate date]
                                                                ttl:30];

                XCTestExpectation *expectation1 = [[XCTestExpectation alloc] initWithDescription:@"expectation1"];
                XCTestExpectation *expectation2 = [[XCTestExpectation alloc] initWithDescription:@"expectation2"];
                XCTestExpectation *expectation3 = [[XCTestExpectation alloc] initWithDescription:@"expectation3"];

                [dbHelper registerTriggerWithTableName:@"shard"
                                           triggerType:[EMSDBTriggerType afterType]
                                          triggerEvent:[EMSDBTriggerEvent insertEvent]
                                               trigger:[[FakeDBTrigger alloc] initWithExpectation:expectation1]];
                [dbHelper registerTriggerWithTableName:@"shard"
                                           triggerType:[EMSDBTriggerType afterType]
                                          triggerEvent:[EMSDBTriggerEvent insertEvent]
                                               trigger:[[FakeDBTrigger alloc] initWithExpectation:expectation2]];
                [dbHelper registerTriggerWithTableName:@"shard"
                                           triggerType:[EMSDBTriggerType afterType]
                                          triggerEvent:[EMSDBTriggerEvent insertEvent]
                                               trigger:[[FakeDBTrigger alloc] initWithExpectation:expectation3]];

                [dbHelper insertModel:shard
                               mapper:[EMSShardMapper new]];

                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation1, expectation2, expectation3]
                                                                timeout:2
                                                           enforceOrder:YES];
                [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
            });

            it(@"should run afterInsert trigger after inserting something in the given table", ^{
                [dbHelper open];
                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id"
                                                               type:@"type"
                                                               data:@{}
                                                          timestamp:[NSDate date]
                                                                ttl:30];

                [dbHelper registerTriggerWithTableName:@"shard"
                                           triggerType:[EMSDBTriggerType afterType]
                                          triggerEvent:[EMSDBTriggerEvent insertEvent]
                                               trigger:dbTrigger];

                [dbHelper insertModel:shard
                               mapper:[EMSShardMapper new]];

                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[defaultExpectation] timeout:2];
                [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];

                NSArray *shards = [dbHelper executeQuery:TEST_SHARD_SELECT_ALL
                                                  mapper:[EMSShardMapper new]];
                EMSShard *expectedShard = [shards lastObject];
                [[shard should] equal:expectedShard];
                [[theValue([shards count]) should] equal:theValue(1)];
            });

            it(@"should run beforeInsert trigger when inserting something in the given table", ^{
                [dbHelper open];
                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id"
                                                               type:@"type"
                                                               data:@{}
                                                          timestamp:[NSDate date]
                                                                ttl:30];

                [dbHelper registerTriggerWithTableName:@"shard"
                                           triggerType:[EMSDBTriggerType beforeType]
                                          triggerEvent:[EMSDBTriggerEvent insertEvent]
                                               trigger:dbTrigger];
                [dbHelper insertModel:shard
                               mapper:[EMSShardMapper new]];

                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[defaultExpectation] timeout:2];
                [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
            });

        });

        describe(@"Database trigger tests", ^{
            const EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id"
                                                                 type:@"type"
                                                                 data:@{}
                                                            timestamp:[NSDate date]
                                                                  ttl:30];

            __block EMSDBTriggerType *type;
            __block EMSDBTriggerEvent *event;
            __block NSNumber *expectedItemCount;
            __block XCTestExpectation *expectation;
            __block NSArray *testDataSet;

            __block id <EMSDBTriggerProtocol> trigger;
            __block void (^actionBlock)();

            beforeEach(^{
                [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                           error:nil];
                schemaHandler = [[EMSSqliteSchemaHandler alloc] init];
                dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                          schemaDelegate:schemaHandler];
                [dbHelper open];
                expectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];

                testDataSet = @[
                    @[
                        [EMSDBTriggerType beforeType],
                        [EMSDBTriggerEvent insertEvent],
                        [[FakeDBTrigger alloc] initWithExpectation:expectation
                                                     triggerAction:^{
                                                         NSArray *shards = [dbHelper executeQuery:SQL_SHARD_SELECTALL
                                                                                           mapper:[EMSShardMapper new]];
                                                         [[theValue([shards count]) should] beZero];
                                                     }],
                        ^{
                            [dbHelper insertModel:shard
                                           mapper:[EMSShardMapper new]];
                        }
                    ],
                    @[
                        [EMSDBTriggerType afterType],
                        [EMSDBTriggerEvent insertEvent],
                        [[FakeDBTrigger alloc] initWithExpectation:expectation
                                                     triggerAction:^{
                                                         NSArray *shards = [dbHelper executeQuery:SQL_SHARD_SELECTALL
                                                                                           mapper:[EMSShardMapper new]];
                                                         [[theValue([shards count]) should] equal:theValue(1)];
                                                     }],
                        ^{
                            [dbHelper insertModel:shard
                                           mapper:[EMSShardMapper new]];
                        }
                    ]

                ];
            });

            afterEach(^{
                [dbHelper close];
            });

            for (NSArray *parameters in testDataSet) {
                type = parameters[0];
                event = parameters[1];
                trigger = parameters[2];
                actionBlock = parameters[3];

                it([NSString stringWithFormat:@"should call the trigger action for %@ %@", type, event], ^{
                    [dbHelper registerTriggerWithTableName:@"shard"
                                               triggerType:type
                                              triggerEvent:event
                                                   trigger:trigger];
                    actionBlock();


                    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:2 enforceOrder:YES];
                    [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
                });
            }

        });

        describe(@"registerTriggerWithTableName:triggerType:triggerEvent:trigger:", ^{

            it(@"should run beforeDelete trigger when deleting something from the given table", ^{
                [dbHelper open];

                [dbHelper registerTriggerWithTableName:@"shard"
                                           triggerType:[EMSDBTriggerType beforeType]
                                          triggerEvent:[EMSDBTriggerEvent deleteEvent]
                                               trigger:dbTrigger];

                EMSShard *model = [[EMSShard alloc] initWithShardId:@"id"
                                                               type:@"type"
                                                               data:@{}
                                                          timestamp:[NSDate date]
                                                                ttl:200.];
                EMSShard *model2 = [[EMSShard alloc] initWithShardId:@"id"
                                                                type:@"type2"
                                                                data:@{}
                                                           timestamp:[NSDate date]
                                                                 ttl:200.];
                EMSShardMapper *mapper = [EMSShardMapper new];

                [dbHelper insertModel:model mapper:mapper];
                [dbHelper insertModel:model2 mapper:mapper];

                [dbHelper removeFromTable:[mapper tableName]
                                selection:@"type=? AND ttl=?"
                            selectionArgs:@[@"type", @"200"]];

                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[defaultExpectation] timeout:2];
                [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];

            });

            it(@"should run beforeDelete and afterDelete trigger in the right sequence when deleting something from the given table", ^{
                [dbHelper open];

                XCTestExpectation *beforeDeleteExpectation = [[XCTestExpectation alloc] initWithDescription:@"beforeDeleteExpectation"];
                XCTestExpectation *afterDeleteExpectation = [[XCTestExpectation alloc] initWithDescription:@"afterDeleteExpectation"];
                [dbHelper registerTriggerWithTableName:@"shard"
                                           triggerType:[EMSDBTriggerType beforeType]
                                          triggerEvent:[EMSDBTriggerEvent deleteEvent]
                                               trigger:[[FakeDBTrigger alloc] initWithExpectation:beforeDeleteExpectation
                                                                                    triggerAction:^{
                                                                                        NSArray *result = [dbHelper executeQuery:SQL_SHARD_SELECTALL
                                                                                                                          mapper:[EMSShardMapper new]];
                                                                                        [[theValue([result count]) should] equal:theValue(2)];
                                                                                    }]
                ];

                [dbHelper registerTriggerWithTableName:@"shard"
                                           triggerType:[EMSDBTriggerType afterType]
                                          triggerEvent:[EMSDBTriggerEvent deleteEvent]
                                               trigger:[[FakeDBTrigger alloc] initWithExpectation:afterDeleteExpectation
                                                                                    triggerAction:^{
                                                                                        NSArray *result = [dbHelper executeQuery:SQL_SHARD_SELECTALL
                                                                                                                          mapper:[EMSShardMapper new]];
                                                                                        [[theValue([result count]) should] equal:theValue(1)];
                                                                                    }]];

                EMSShard *model = [[EMSShard alloc] initWithShardId:@"id"
                                                               type:@"type"
                                                               data:@{}
                                                          timestamp:[NSDate date]
                                                                ttl:200.];
                EMSShard *model2 = [[EMSShard alloc] initWithShardId:@"id"
                                                                type:@"type2"
                                                                data:@{}
                                                           timestamp:[NSDate date]
                                                                 ttl:200.];
                EMSShardMapper *mapper = [EMSShardMapper new];

                [dbHelper insertModel:model mapper:mapper];
                [dbHelper insertModel:model2 mapper:mapper];

                [dbHelper removeFromTable:[mapper tableName]
                                selection:@"type=? AND ttl=?"
                            selectionArgs:@[@"type", @"200"]];

                XCTWaiterResult result = [XCTWaiter waitForExpectations:@[beforeDeleteExpectation, afterDeleteExpectation]
                                                                timeout:2
                                                           enforceOrder:YES];
                [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
            });
        });

        describe(@"registeredTriggers", ^{
            it(@"should run return the registered triggers", ^{

                id afterInsertTrigger = [KWMock mockForProtocol:@protocol(EMSDBTriggerProtocol)];
                id beforeInsertTrigger = [KWMock mockForProtocol:@protocol(EMSDBTriggerProtocol)];
                id afterDeleteTrigger = [KWMock mockForProtocol:@protocol(EMSDBTriggerProtocol)];
                id beforeDeleteTrigger = [KWMock mockForProtocol:@protocol(EMSDBTriggerProtocol)];

                [dbHelper registerTriggerWithTableName:@"shard"
                                           triggerType:[EMSDBTriggerType afterType]
                                          triggerEvent:[EMSDBTriggerEvent insertEvent]
                                               trigger:afterInsertTrigger];
                [dbHelper registerTriggerWithTableName:@"shard"
                                           triggerType:[EMSDBTriggerType beforeType]
                                          triggerEvent:[EMSDBTriggerEvent insertEvent]
                                               trigger:beforeInsertTrigger];
                [dbHelper registerTriggerWithTableName:@"shard"
                                           triggerType:[EMSDBTriggerType afterType]
                                          triggerEvent:[EMSDBTriggerEvent deleteEvent]
                                               trigger:afterDeleteTrigger];
                [dbHelper registerTriggerWithTableName:@"shard"
                                           triggerType:[EMSDBTriggerType beforeType]
                                          triggerEvent:[EMSDBTriggerEvent deleteEvent]
                                               trigger:beforeDeleteTrigger];

                NSArray *afterInsertTriggers = dbHelper.registeredTriggers[
                    [[EMSDBTriggerKey alloc] initWithTableName:@"shard"
                                                     withEvent:[EMSDBTriggerEvent insertEvent]
                                                      withType:[EMSDBTriggerType afterType]]];

                NSArray *beforeInsertTriggers = dbHelper.registeredTriggers[
                    [[EMSDBTriggerKey alloc] initWithTableName:@"shard"
                                                     withEvent:[EMSDBTriggerEvent insertEvent]
                                                      withType:[EMSDBTriggerType beforeType]]];

                NSArray *beforeDeleteTriggers = dbHelper.registeredTriggers[
                    [[EMSDBTriggerKey alloc] initWithTableName:@"shard"
                                                     withEvent:[EMSDBTriggerEvent deleteEvent]
                                                      withType:[EMSDBTriggerType beforeType]]];

                NSArray *afterDeleteTriggers = dbHelper.registeredTriggers[
                    [[EMSDBTriggerKey alloc] initWithTableName:@"shard"
                                                     withEvent:[EMSDBTriggerEvent deleteEvent]
                                                      withType:[EMSDBTriggerType afterType]]];

                [[afterInsertTriggers should] equal:@[afterInsertTrigger]];
                [[beforeInsertTriggers should] equal:@[beforeInsertTrigger]];
                [[afterDeleteTriggers should] equal:@[afterDeleteTrigger]];
                [[beforeDeleteTriggers should] equal:@[beforeDeleteTrigger]];
            });
        });

SPEC_END
