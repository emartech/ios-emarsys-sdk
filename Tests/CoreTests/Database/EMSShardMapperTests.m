//
//  Copyright (c) 2026 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSShardMapper.h"
#import "EMSShard.h"
#import "EMSSchemaContract.h"
#import "EMSSQLiteHelper.h"
#import "EMSSqliteSchemaHandler.h"
#import "XCTestCase+Helper.h"
#import "EmarsysTestUtils.h"
#import "NSOperationQueue+EMSCore.h"

#define TEST_MAPPER_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"ShardMapperTestDB.db"]

@interface EMSShardMapperTests : XCTestCase

@property(nonatomic, strong) EMSSQLiteHelper *dbHelper;
@property(nonatomic, strong) EMSShardMapper *mapper;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EMSShardMapperTests

- (void)setUp {
    [super setUp];
    _operationQueue = [self createTestOperationQueue];
    EMSSqliteSchemaHandler *schemaHandler = [[EMSSqliteSchemaHandler alloc] init];
    _dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_MAPPER_DB_PATH
                                               schemaDelegate:schemaHandler
                                               operationQueue:self.operationQueue];
    [self.dbHelper open];
    _mapper = [EMSShardMapper new];
}

- (void)tearDown {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [EmarsysTestUtils clearDb:weakSelf.dbHelper];
    }];
    [self.dbHelper close];
    [[NSFileManager defaultManager] removeItemAtPath:TEST_MAPPER_DB_PATH error:nil];
    [super tearDown];
}

- (void)testModelFromStatement_shouldReturnShardWithEmptyData_whenDataColumnIsNull {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [weakSelf.dbHelper executeCommand:@"INSERT INTO shard (shard_id, type, data, timestamp, ttl) VALUES ('testId', 'testType', NULL, 1234.0, 200.0);"];
    }];

    NSArray *result = [self.dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:self.mapper];

    XCTAssertEqual(result.count, 1);
    EMSShard *shard = result.firstObject;
    XCTAssertNotNil(shard);
    XCTAssertEqualObjects(shard.shardId, @"testId");
    XCTAssertEqualObjects(shard.type, @"testType");
    XCTAssertEqualObjects(shard.data, @{});
    XCTAssertEqual(shard.ttl, 200.0);
}

- (void)testModelFromStatement_shouldReturnNil_whenShardIdColumnIsNull {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [weakSelf.dbHelper executeCommand:@"INSERT INTO shard (shard_id, type, data, timestamp, ttl) VALUES (NULL, 'testType', NULL, 1234.0, 200.0);"];
    }];

    NSArray *result = [self.dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:self.mapper];

    XCTAssertEqual(result.count, 0);
}

- (void)testModelFromStatement_shouldReturnNil_whenTypeColumnIsNull {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [weakSelf.dbHelper executeCommand:@"INSERT INTO shard (shard_id, type, data, timestamp, ttl) VALUES ('testId', NULL, NULL, 1234.0, 200.0);"];
    }];

    NSArray *result = [self.dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:self.mapper];

    XCTAssertEqual(result.count, 0);
}

- (void)testModelFromStatement_shouldSkipInvalidRows_andReturnValidOnes {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [weakSelf.dbHelper executeCommand:@"INSERT INTO shard (shard_id, type, data, timestamp, ttl) VALUES (NULL, 'testType', NULL, 1234.0, 200.0);"];
        [weakSelf.dbHelper executeCommand:@"INSERT INTO shard (shard_id, type, data, timestamp, ttl) VALUES ('validId', 'testType', NULL, 1234.0, 200.0);"];
        [weakSelf.dbHelper executeCommand:@"INSERT INTO shard (shard_id, type, data, timestamp, ttl) VALUES (NULL, NULL, NULL, 1234.0, 200.0);"];
    }];

    NSArray *result = [self.dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:self.mapper];

    XCTAssertEqual(result.count, 1);
    EMSShard *shard = result.firstObject;
    XCTAssertEqualObjects(shard.shardId, @"validId");
}

- (void)testModelFromStatement_shouldReturnShardWithEmptyData_whenBlobDataIsCorrupt {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [weakSelf.dbHelper executeCommand:@"INSERT INTO shard (shard_id, type, data, timestamp, ttl) VALUES ('testId', 'testType', X'DEADBEEF', 1234.0, 200.0);"];
    }];

    NSArray *result = [self.dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:self.mapper];

    XCTAssertEqual(result.count, 1);
    EMSShard *shard = result.firstObject;
    XCTAssertNotNil(shard);
    XCTAssertEqualObjects(shard.data, @{});
}

- (void)testModelFromStatement_shouldReturnValidShard_whenTtlIsZero {
    EMSShard *model = [[EMSShard alloc] initWithShardId:@"id"
                                                   type:@"type"
                                                   data:@{@"key": @"value"}
                                              timestamp:[NSDate dateWithTimeIntervalSince1970:1234.0]
                                                    ttl:0.0];

    [self.dbHelper insertModel:model mapper:self.mapper];
    NSArray *result = [self.dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:self.mapper];

    XCTAssertEqual(result.count, 1);
    EMSShard *shard = result.firstObject;
    XCTAssertNotNil(shard);
    XCTAssertEqual(shard.ttl, 0.0);
    XCTAssertEqualObjects(shard.shardId, @"id");
    XCTAssertEqualObjects(shard.type, @"type");
    XCTAssertEqualObjects(shard.data, @{@"key": @"value"});
}

- (void)testModelFromStatement_shouldReturnShardWithZeroTtl_whenTtlColumnIsZeroViaRawSql {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [weakSelf.dbHelper executeCommand:@"INSERT INTO shard (shard_id, type, data, timestamp, ttl) VALUES ('testId', 'testType', NULL, 1234.0, 0.0);"];
    }];

    NSArray *result = [self.dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:self.mapper];

    XCTAssertEqual(result.count, 1);
    EMSShard *shard = result.firstObject;
    XCTAssertNotNil(shard);
    XCTAssertEqual(shard.ttl, 0.0);
    XCTAssertEqualObjects(shard.shardId, @"testId");
}

- (void)testRoundTrip_shouldPreserveAllFields {
    NSDictionary *data = @{
        @"key1": @"value1",
        @"key2": @(42),
        @"key3": @[@"a", @"b"]
    };
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:1710000000.0];
    EMSShard *original = [[EMSShard alloc] initWithShardId:@"shard123"
                                                      type:@"testType"
                                                      data:data
                                                 timestamp:timestamp
                                                       ttl:300.0];

    [self.dbHelper insertModel:original mapper:self.mapper];
    NSArray *result = [self.dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:self.mapper];

    XCTAssertEqual(result.count, 1);
    EMSShard *loaded = result.firstObject;
    XCTAssertEqualObjects(loaded.shardId, original.shardId);
    XCTAssertEqualObjects(loaded.type, original.type);
    XCTAssertEqualObjects(loaded.data, original.data);
    XCTAssertEqual(loaded.ttl, original.ttl);
    XCTAssertEqualObjects(loaded, original);
}

- (void)testRoundTrip_shouldPreserveEmptyDictionary {
    EMSShard *original = [[EMSShard alloc] initWithShardId:@"shard123"
                                                      type:@"testType"
                                                      data:@{}
                                                 timestamp:[NSDate dateWithTimeIntervalSince1970:1234.0]
                                                       ttl:100.0];

    [self.dbHelper insertModel:original mapper:self.mapper];
    NSArray *result = [self.dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:self.mapper];

    XCTAssertEqual(result.count, 1);
    EMSShard *loaded = result.firstObject;
    XCTAssertEqualObjects(loaded.data, @{});
    XCTAssertEqualObjects(loaded, original);
}

- (void)testQueryWithTable_shouldNotCrash_whenMapperReturnsNilForInvalidRows {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [weakSelf.dbHelper executeCommand:@"INSERT INTO shard (shard_id, type, data, timestamp, ttl) VALUES (NULL, NULL, NULL, 1234.0, 200.0);"];
        [weakSelf.dbHelper executeCommand:@"INSERT INTO shard (shard_id, type, data, timestamp, ttl) VALUES ('validId', 'type', NULL, 1234.0, 200.0);"];
    }];

    NSArray *result = [self.dbHelper queryWithTable:SHARD_TABLE_NAME
                                          selection:nil
                                      selectionArgs:nil
                                            orderBy:nil
                                              limit:nil
                                             mapper:self.mapper];

    XCTAssertEqual(result.count, 1);
    EMSShard *shard = result.firstObject;
    XCTAssertEqualObjects(shard.shardId, @"validId");
}

- (void)testQueryWithTable_shouldReturnEmptyArray_whenAllRowsAreInvalid {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [weakSelf.dbHelper executeCommand:@"INSERT INTO shard (shard_id, type, data, timestamp, ttl) VALUES (NULL, NULL, NULL, 1234.0, 200.0);"];
        [weakSelf.dbHelper executeCommand:@"INSERT INTO shard (shard_id, type, data, timestamp, ttl) VALUES (NULL, 'type', NULL, 1234.0, 200.0);"];
    }];

    NSArray *result = [self.dbHelper queryWithTable:SHARD_TABLE_NAME
                                          selection:nil
                                      selectionArgs:nil
                                            orderBy:nil
                                              limit:nil
                                             mapper:self.mapper];

    XCTAssertNotNil(result);
    XCTAssertEqual(result.count, 0);
}

@end
