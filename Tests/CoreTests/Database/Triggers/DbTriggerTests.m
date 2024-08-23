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
#import "EmarsysTestUtils.h"
#import <OCMock/OCMock.h>
#import "XCTestCase+Helper.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]
#define TEST_SHARD_SELECT_ALL @"SELECT * FROM shard ORDER BY ROWID ASC;"

@interface DBTriggerTests : XCTestCase

@property (nonatomic, strong) EMSSQLiteHelper *dbHelper;
@property (nonatomic, strong) EMSSqliteSchemaHandler *schemaHandler;
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation DBTriggerTests

- (void)setUp {
    [super setUp];
    _queue = [self createTestOperationQueue];
    self.schemaHandler = [[EMSSqliteSchemaHandler alloc] init];
    self.dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH 
                                                   schemaDelegate:self.schemaHandler
                                                   operationQueue:self.queue];
    [self.dbHelper open];
}

- (void)tearDown {
    [EmarsysTestUtils clearDb:self.dbHelper];
    [super tearDown];
}

- (void)testRegisterTriggerWithTableNameTriggerTypeTriggerEventTrigger_afterInsert {
    XCTestExpectation *defaultExpectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];
    id<EMSDBTriggerProtocol> dbTrigger = [[FakeDBTrigger alloc] initWithExpectation:defaultExpectation];

    EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:30];

    [self.dbHelper registerTriggerWithTableName:@"shard" triggerType:[EMSDBTriggerType afterType] triggerEvent:[EMSDBTriggerEvent insertEvent] trigger:dbTrigger];
    [self.dbHelper insertModel:shard mapper:[EMSShardMapper new]];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[defaultExpectation] timeout:10];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
}

- (void)testRegisterTriggerWithTableNameTriggerTypeTriggerEventTrigger_allAfterInsert {
    EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:30];

    XCTestExpectation *expectation1 = [[XCTestExpectation alloc] initWithDescription:@"expectation1"];
    XCTestExpectation *expectation2 = [[XCTestExpectation alloc] initWithDescription:@"expectation2"];
    XCTestExpectation *expectation3 = [[XCTestExpectation alloc] initWithDescription:@"expectation3"];

    [self.dbHelper registerTriggerWithTableName:@"shard" triggerType:[EMSDBTriggerType afterType] triggerEvent:[EMSDBTriggerEvent insertEvent] trigger:[[FakeDBTrigger alloc] initWithExpectation:expectation1]];
    [self.dbHelper registerTriggerWithTableName:@"shard" triggerType:[EMSDBTriggerType afterType] triggerEvent:[EMSDBTriggerEvent insertEvent] trigger:[[FakeDBTrigger alloc] initWithExpectation:expectation2]];
    [self.dbHelper registerTriggerWithTableName:@"shard" triggerType:[EMSDBTriggerType afterType] triggerEvent:[EMSDBTriggerEvent insertEvent] trigger:[[FakeDBTrigger alloc] initWithExpectation:expectation3]];

    [self.dbHelper insertModel:shard mapper:[EMSShardMapper new]];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation1, expectation2, expectation3] timeout:2 enforceOrder:YES];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
}

- (void)testRegisterTriggerWithTableNameTriggerTypeTriggerEventTrigger_afterInsert_verifyData {
    XCTestExpectation *defaultExpectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];
    id<EMSDBTriggerProtocol> dbTrigger = [[FakeDBTrigger alloc] initWithExpectation:defaultExpectation];

    EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:30];

    [self.dbHelper registerTriggerWithTableName:@"shard" triggerType:[EMSDBTriggerType afterType] triggerEvent:[EMSDBTriggerEvent insertEvent] trigger:dbTrigger];

    [self.dbHelper insertModel:shard mapper:[EMSShardMapper new]];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[defaultExpectation] timeout:10];
    XCTAssertEqual(result, XCTWaiterResultCompleted);

    NSArray *shards = [self.dbHelper executeQuery:TEST_SHARD_SELECT_ALL mapper:[EMSShardMapper new]];
    EMSShard *expectedShard = [shards lastObject];
    XCTAssertEqualObjects(shard, expectedShard);
    XCTAssertEqual([shards count], 1);
}

- (void)testRegisterTriggerWithTableNameTriggerTypeTriggerEventTrigger_beforeInsert {
    XCTestExpectation *defaultExpectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];
    id<EMSDBTriggerProtocol> dbTrigger = [[FakeDBTrigger alloc] initWithExpectation:defaultExpectation];

    EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:30];

    [self.dbHelper registerTriggerWithTableName:@"shard" triggerType:[EMSDBTriggerType beforeType] triggerEvent:[EMSDBTriggerEvent insertEvent] trigger:dbTrigger];
    [self.dbHelper insertModel:shard mapper:[EMSShardMapper new]];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[defaultExpectation] timeout:10];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
}

- (void)testTriggerActions {
    const EMSShard *shard = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:30];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];
    [expectation setExpectedFulfillmentCount:2];
    NSArray *testDataSet = @[
        @[ [EMSDBTriggerType beforeType], [EMSDBTriggerEvent insertEvent], [[FakeDBTrigger alloc] initWithExpectation:[[XCTestExpectation alloc] initWithDescription:@"expectation"]
        triggerAction:^{
            [expectation fulfill];
        }], ^{
            [self.dbHelper insertModel:shard mapper:[EMSShardMapper new]];
        }],
        @[ [EMSDBTriggerType afterType], [EMSDBTriggerEvent insertEvent], [[FakeDBTrigger alloc] initWithExpectation:[[XCTestExpectation alloc] initWithDescription:@"expectation"]
        triggerAction:^{
            [expectation fulfill];
        }], ^{
            [self.dbHelper insertModel:shard mapper:[EMSShardMapper new]];
        }]
    ];

    for (NSArray *parameters in testDataSet) {
        EMSDBTriggerType *type = parameters[0];
        EMSDBTriggerEvent *event = parameters[1];
        id<EMSDBTriggerProtocol> trigger = parameters[2];
        void (^actionBlock)() = parameters[3];

        [self.dbHelper registerTriggerWithTableName:@"shard" triggerType:type triggerEvent:event trigger:trigger];
        actionBlock();

    }
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:2 enforceOrder:YES];
    XCTAssertEqual(result, XCTWaiterResultCompleted);

}

- (void)testRegisterTriggerWithTableNameTriggerTypeTriggerEventTrigger_beforeDelete {
    XCTestExpectation *defaultExpectation = [[XCTestExpectation alloc] initWithDescription:@"expectation"];
    id<EMSDBTriggerProtocol> dbTrigger = [[FakeDBTrigger alloc] initWithExpectation:defaultExpectation];

    [self.dbHelper registerTriggerWithTableName:@"shard" triggerType:[EMSDBTriggerType beforeType] triggerEvent:[EMSDBTriggerEvent deleteEvent] trigger:dbTrigger];

    EMSShard *model = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:200.];
    EMSShard *model2 = [[EMSShard alloc] initWithShardId:@"id" type:@"type2" data:@{} timestamp:[NSDate date] ttl:200.];
    EMSShardMapper *mapper = [EMSShardMapper new];

    [self.dbHelper insertModel:model mapper:mapper];
    [self.dbHelper insertModel:model2 mapper:mapper];

    [self.dbHelper removeFromTable:[mapper tableName] selection:@"type=? AND ttl=?" selectionArgs:@[@"type", @"200"]];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[defaultExpectation] timeout:10];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
}

- (void)testRegisterTriggerWithTableNameTriggerTypeTriggerEventTrigger_beforeAfterDeleteSequence {
    XCTestExpectation *beforeDeleteExpectation = [[XCTestExpectation alloc] initWithDescription:@"beforeDeleteExpectation"];
    XCTestExpectation *afterDeleteExpectation = [[XCTestExpectation alloc] initWithDescription:@"afterDeleteExpectation"];

    [self.dbHelper registerTriggerWithTableName:@"shard" triggerType:[EMSDBTriggerType beforeType] triggerEvent:[EMSDBTriggerEvent deleteEvent] trigger:[[FakeDBTrigger alloc] initWithExpectation:beforeDeleteExpectation triggerAction:^{
        NSArray *result = [self.dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:[EMSShardMapper new]];
        XCTAssertEqual([result count], 2);
    }]];

    [self.dbHelper registerTriggerWithTableName:@"shard" triggerType:[EMSDBTriggerType afterType] triggerEvent:[EMSDBTriggerEvent deleteEvent] trigger:[[FakeDBTrigger alloc] initWithExpectation:afterDeleteExpectation triggerAction:^{
        NSArray *result = [self.dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:[EMSShardMapper new]];
        XCTAssertEqual([result count], 1);
    }]];

    EMSShard *model = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:200.];
    EMSShard *model2 = [[EMSShard alloc] initWithShardId:@"id" type:@"type2" data:@{} timestamp:[NSDate date] ttl:200.];
    EMSShardMapper *mapper = [EMSShardMapper new];

    [self.dbHelper insertModel:model mapper:mapper];
    [self.dbHelper insertModel:model2 mapper:mapper];

    [self.dbHelper removeFromTable:[mapper tableName] selection:@"type=? AND ttl=?" selectionArgs:@[@"type", @"200"]];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[beforeDeleteExpectation, afterDeleteExpectation] timeout:2 enforceOrder:YES];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
}

- (void)testRegisteredTriggers {
    id afterInsertTrigger = OCMProtocolMock(@protocol(EMSDBTriggerProtocol));
    id beforeInsertTrigger = OCMProtocolMock(@protocol(EMSDBTriggerProtocol));
    id afterDeleteTrigger = OCMProtocolMock(@protocol(EMSDBTriggerProtocol));
    id beforeDeleteTrigger = OCMProtocolMock(@protocol(EMSDBTriggerProtocol));

    [self.dbHelper registerTriggerWithTableName:@"shard" triggerType:[EMSDBTriggerType afterType] triggerEvent:[EMSDBTriggerEvent insertEvent] trigger:afterInsertTrigger];
    [self.dbHelper registerTriggerWithTableName:@"shard" triggerType:[EMSDBTriggerType beforeType] triggerEvent:[EMSDBTriggerEvent insertEvent] trigger:beforeInsertTrigger];
    [self.dbHelper registerTriggerWithTableName:@"shard" triggerType:[EMSDBTriggerType afterType] triggerEvent:[EMSDBTriggerEvent deleteEvent] trigger:afterDeleteTrigger];
    [self.dbHelper registerTriggerWithTableName:@"shard" triggerType:[EMSDBTriggerType beforeType] triggerEvent:[EMSDBTriggerEvent deleteEvent] trigger:beforeDeleteTrigger];

    NSArray *afterInsertTriggers = self.dbHelper.registeredTriggers[[[EMSDBTriggerKey alloc] initWithTableName:@"shard" withEvent:[EMSDBTriggerEvent insertEvent] withType:[EMSDBTriggerType afterType]]];
    NSArray *beforeInsertTriggers = self.dbHelper.registeredTriggers[[[EMSDBTriggerKey alloc] initWithTableName:@"shard" withEvent:[EMSDBTriggerEvent insertEvent] withType:[EMSDBTriggerType beforeType]]];
    NSArray *beforeDeleteTriggers = self.dbHelper.registeredTriggers[[[EMSDBTriggerKey alloc] initWithTableName:@"shard" withEvent:[EMSDBTriggerEvent deleteEvent] withType:[EMSDBTriggerType beforeType]]];
    NSArray *afterDeleteTriggers = self.dbHelper.registeredTriggers[[[EMSDBTriggerKey alloc] initWithTableName:@"shard" withEvent:[EMSDBTriggerEvent deleteEvent] withType:[EMSDBTriggerType afterType]]];

    XCTAssertEqualObjects(afterInsertTriggers, @[afterInsertTrigger]);
    XCTAssertEqualObjects(beforeInsertTriggers, @[beforeInsertTrigger]);
    XCTAssertEqualObjects(afterDeleteTriggers, @[afterDeleteTrigger]);
    XCTAssertEqualObjects(beforeDeleteTriggers, @[beforeDeleteTrigger]);
}

@end
