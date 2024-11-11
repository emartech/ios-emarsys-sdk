//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import <OCMock/OCMock.h>
#import "EMSSQLiteHelper.h"
#import "EMSSqliteSchemaHandler.h"
#import "EMSRequestModel.h"
#import "EMSSchemaContract.h"
#import "EMSRequestModelMapper.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSSQLiteHelper+Test.h"
#import "EMSShard.h"
#import "EMSShardMapper.h"
#import "EMSQueryOldestRowSpecification.h"
#import "EmarsysTestUtils.h"
#import "EMSTestColumnInfo.h"
#import "EMSTestColumnInfoMapper.h"
#import "XCTestCase+Helper.h"
#import "NSOperationQueue+EMSCore.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

@interface EMSSQLiteHelperTests: XCTestCase

@property(nonatomic, strong) EMSSQLiteHelper *dbHelper;
@property(nonatomic, strong) EMSSqliteSchemaHandler *schemaHandler;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EMSSQLiteHelperTests

- (void)setUp {
    [super setUp];
    _schemaHandler = [[EMSSqliteSchemaHandler alloc] init];
    _operationQueue = [self createTestOperationQueue];
    _dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                               schemaDelegate:self.schemaHandler
                                               operationQueue:self.operationQueue];
    [self.dbHelper open];
}

- (void)tearDown {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [weakSelf.dbHelper executeCommand:@"PRAGMA user_version=1;"];
        [EmarsysTestUtils clearDb:weakSelf.dbHelper];
    }];
    [super tearDown];
}

- (void)testGetVersion {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [weakSelf.dbHelper executeCommand:@"PRAGMA user_version=1;"];
        XCTAssertEqual([weakSelf.dbHelper version], 1);
    }];
}

- (void)testOpenDatabase {
    EMSSqliteSchemaHandler *schemaDelegate = OCMClassMock([EMSSqliteSchemaHandler class]);
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [weakSelf.dbHelper executeCommand:@"PRAGMA user_version=0;"];
    }];
    self.dbHelper.schemaHandler = schemaDelegate;
    OCMExpect([schemaDelegate onCreateWithDbHelper:OCMOCK_ANY]);

    
    [self.dbHelper open];
    
    OCMVerifyAll(schemaDelegate);
}

- (void)testOpenDatabaseWithUpgrade {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [weakSelf.dbHelper executeCommand:@"PRAGMA user_version=2;"];
    }];
    EMSSqliteSchemaHandler *schemaDelegate = OCMClassMock([EMSSqliteSchemaHandler class]);
    self.dbHelper.schemaHandler = schemaDelegate;
    OCMStub([schemaDelegate schemaVersion]).andReturn(100);
    OCMExpect([schemaDelegate onUpgradeWithDbHelper:OCMOCK_ANY oldVersion:2 newVersion:100]);
    
    [self.dbHelper open];
    
    OCMVerifyAll(schemaDelegate);
}

- (void)testExecuteCommandFailure {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        BOOL returnedValue = [weakSelf.dbHelper executeCommand:@"invalid sql;"];
        XCTAssertFalse(returnedValue);
    }];
}

- (void)testRemoveFromTableWithoutWhereClause {
    EMSSqliteSchemaHandler *schemaDelegate = [EMSSqliteSchemaHandler new];
    [self.dbHelper setSchemaHandler:schemaDelegate];
    EMSShard *model = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:200.0];
    EMSShardMapper *mapper = [EMSShardMapper new];
    
    [self.dbHelper insertModel:model mapper:mapper];
    [self.dbHelper insertModel:model mapper:mapper];
    [self.dbHelper removeFromTable:[mapper tableName] selection:nil selectionArgs:nil];
    
    NSArray *result = [self.dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:mapper];
    XCTAssertTrue(result.count == 0);
}

- (void)testRemoveFromTableWithWhereClause {
    EMSSqliteSchemaHandler *schemaDelegate = [EMSSqliteSchemaHandler new];
    [self.dbHelper setSchemaHandler:schemaDelegate];
    EMSShard *model = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:200.0];
    EMSShard *model2 = [[EMSShard alloc] initWithShardId:@"id" type:@"type2" data:@{} timestamp:[NSDate date] ttl:200.0];
    EMSShardMapper *mapper = [EMSShardMapper new];
    
    [self.dbHelper insertModel:model mapper:mapper];
    [self.dbHelper insertModel:model2 mapper:mapper];
    [self.dbHelper removeFromTable:[mapper tableName] selection:@"type=? AND ttl=?" selectionArgs:@[@"type", @"200"]];
    
    NSArray *result = [self.dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:mapper];
    XCTAssertTrue([result containsObject:model2]);
    XCTAssertFalse([result containsObject:model]);
    XCTAssertEqual(result.count, 1);
}

- (void)testRemoveFromTableWithWhereClauseNoMatch {
    EMSSqliteSchemaHandler *schemaDelegate = [EMSSqliteSchemaHandler new];
    [self.dbHelper setSchemaHandler:schemaDelegate];
    EMSShard *model = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:200.0];
    EMSShard *model2 = [[EMSShard alloc] initWithShardId:@"id" type:@"type2" data:@{} timestamp:[NSDate date] ttl:200.0];
    EMSShardMapper *mapper = [EMSShardMapper new];
    
    [self.dbHelper insertModel:model mapper:mapper];
    [self.dbHelper insertModel:model2 mapper:mapper];
    [self.dbHelper removeFromTable:[mapper tableName] selection:@"type=? AND ttl=?" selectionArgs:@[@"type", @"300"]];
    
    NSArray *result = [self.dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:mapper];
    XCTAssertTrue([result containsObject:model2]);
    XCTAssertTrue([result containsObject:model]);
    XCTAssertEqual(result.count, 2);
}

- (void)testQueryWithTable {
    EMSShard *model = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:200.0];
    NSArray *expectedResult = @[model, model];
    
    EMSShardMapper *mapper = [EMSShardMapper new];
    
    [self.dbHelper insertModel:model mapper:mapper];
    [self.dbHelper insertModel:model mapper:mapper];
    
    NSArray *result = [self.dbHelper queryWithTable:mapper.tableName selection:nil selectionArgs:nil orderBy:nil limit:nil mapper:mapper];
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)testQueryWithType {
    EMSShard *model = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:200.0];
    EMSShard *model2 = [[EMSShard alloc] initWithShardId:@"id2" type:@"shard" data:@{} timestamp:[NSDate date] ttl:200.0];
    NSArray *expectedResult = @[model2];
    
    EMSShardMapper *mapper = [EMSShardMapper new];
    
    [self.dbHelper insertModel:model mapper:mapper];
    [self.dbHelper insertModel:model2 mapper:mapper];
    
    NSArray *result = [self.dbHelper queryWithTable:mapper.tableName selection:@"type LIKE ?" selectionArgs:@[@"shard"] orderBy:nil limit:nil mapper:mapper];
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)testQueryWithLimit {
    EMSRequestModel *model = [self requestModelWithUrl:@"https://www.google.com" payload:@{@"key": @"value"}];
    EMSRequestModel *model2 = [self requestModelWithUrl:@"https://www.google.com" payload:@{@"key": @"value"}];
    
    NSArray *expectedResult = @[model];
    
    EMSRequestModelMapper *mapper = [EMSRequestModelMapper new];
    
    [self.dbHelper insertModel:model mapper:mapper];
    [self.dbHelper insertModel:model2 mapper:mapper];
    
    NSArray *result = [self.dbHelper queryWithTable:mapper.tableName selection:nil selectionArgs:nil orderBy:@"ROWID ASC" limit:@"1" mapper:mapper];
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)testInsertModelWithQuery {
    EMSRequestModel *model = [self requestModelWithUrl:@"https://www.google.com" payload:@{@"key": @"value"}];
    EMSRequestModelMapper *mapper = [EMSRequestModelMapper new];
    
    BOOL returnedValue = [self.dbHelper insertModel:model withQuery:SQL_REQUEST_INSERT mapper:mapper];
    NSArray *requests = [self.dbHelper executeQuery:SQL_REQUEST_SELECTFIRST mapper:mapper];
    
    EMSRequestModel *request = [requests firstObject];
    
    XCTAssertTrue(returnedValue);
    XCTAssertEqualObjects(model, request);
}

- (void)testInsertModel {
    EMSRequestModel *model = [self requestModelWithUrl:@"https://www.google.com" payload:@{@"key": @"value"}];
    EMSRequestModelMapper *mapper = [EMSRequestModelMapper new];
    
    BOOL returnedValue = [self.dbHelper insertModel:model mapper:mapper];
    NSArray *requests = [self.dbHelper executeQuery:SQL_REQUEST_SELECTFIRST mapper:mapper];
    
    EMSRequestModel *request = [requests firstObject];
    
    XCTAssertTrue(returnedValue);
    XCTAssertEqualObjects(model, request);
}

- (void)testInsertShard {
    EMSShard *model = [[EMSShard alloc] initWithShardId:@"id" type:@"type" data:@{} timestamp:[NSDate date] ttl:200.0];
    EMSShardMapper *mapper = [EMSShardMapper new];
    
    BOOL returnedValue = [self.dbHelper insertModel:model mapper:mapper];
    NSArray *shards = [self.dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:mapper];
    
    EMSShard *expectedShard = [shards lastObject];
    
    XCTAssertTrue(returnedValue);
    XCTAssertEqualObjects(model, expectedShard);
}

- (void)testSchemaHandlerOnCreate {
    NSArray<EMSTestColumnInfo *> *expectedRequestColumnInfos = [self tableSchemes:@"request"];
    NSArray<EMSTestColumnInfo *> *expectedShardColumnInfos = [self tableSchemes:@"shard"];

    
    NSArray<EMSTestColumnInfo *> *currentRequestColumnInfos = [self tableSchemes:@"request"];
    NSArray<EMSTestColumnInfo *> *currentShardColumnInfos = [self tableSchemes:@"shard"];
    
    [self isEqualArrays:expectedRequestColumnInfos currentArray:currentRequestColumnInfos];
    [self isEqualArrays:expectedShardColumnInfos currentArray:currentShardColumnInfos];
    
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        XCTAssertEqual([weakSelf.dbHelper version], 1);
    }];
}

- (void)testSchemaMigration {
    [self tearDown];
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [weakSelf.dbHelper executeCommand:@"DROP TABLE shard;"];
        [weakSelf.dbHelper executeCommand:@"DROP TABLE request;"];
        [weakSelf.dbHelper executeCommand:@"PRAGMA user_version=0;"];
    }];

    NSArray<EMSTestColumnInfo *> *expectedRequestColumnInfos = @[
        [[EMSTestColumnInfo alloc] initWithColumnName:@"request_id" columnType:@"TEXT"],
        [[EMSTestColumnInfo alloc] initWithColumnName:@"method" columnType:@"TEXT"],
        [[EMSTestColumnInfo alloc] initWithColumnName:@"url" columnType:@"TEXT"],
        [[EMSTestColumnInfo alloc] initWithColumnName:@"headers" columnType:@"BLOB"],
        [[EMSTestColumnInfo alloc] initWithColumnName:@"payload" columnType:@"BLOB"],
        [[EMSTestColumnInfo alloc] initWithColumnName:@"timestamp" columnType:@"REAL"],
        [[EMSTestColumnInfo alloc] initWithColumnName:@"expiry" columnType:@"DOUBLE" defaultValue:[NSString stringWithFormat:@"%f", DEFAULT_REQUESTMODEL_EXPIRY] primaryKey:NO notNull:NO]
    ];
    NSArray<EMSTestColumnInfo *> *expectedShardColumnInfos = @[
        [[EMSTestColumnInfo alloc] initWithColumnName:@"shard_id" columnType:@"TEXT"],
        [[EMSTestColumnInfo alloc] initWithColumnName:@"type"
                                           columnType:@"TEXT"],
        [[EMSTestColumnInfo alloc] initWithColumnName:@"data"
                                           columnType:@"BLOB"],
        [[EMSTestColumnInfo alloc] initWithColumnName:@"timestamp"
                                           columnType:@"REAL"],
        [[EMSTestColumnInfo alloc] initWithColumnName:@"ttl"
                                           columnType:@"REAL"]
    ];
    
    [self.schemaHandler onUpgradeWithDbHelper:self.dbHelper
                              oldVersion:0
                              newVersion:1];
    
    NSArray<EMSTestColumnInfo *> *currentRequestColumnInfos = [self tableSchemes:@"request"];
    NSArray<EMSTestColumnInfo *> *currentShardColumnInfos = [self tableSchemes:@"shard"];
    
    XCTAssertEqualObjects(expectedRequestColumnInfos, currentRequestColumnInfos);
    XCTAssertEqualObjects(expectedShardColumnInfos, currentShardColumnInfos);
    
    [self.operationQueue runSynchronized:^{
        XCTAssertEqual([weakSelf.dbHelper version], 1);
    }];

}

- (id)requestModelWithUrl:(NSString *)url payload:(NSDictionary *)payload {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:url];
        [builder setMethod:HTTPMethodPOST];
        [builder setPayload:payload];
        [builder setHeaders:@{@"headerKey": @"headerValue"}];
    } timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
}

- (NSArray<EMSTestColumnInfo *> *)tableSchemes:(NSString *)tableName {
    return [self.dbHelper executeQuery:[NSString stringWithFormat:@"PRAGMA table_info(%@);", tableName] mapper:[[EMSTestColumnInfoMapper alloc] initWithTableName:tableName]];
}

- (void)isEqualArrays:(NSArray *)expectedArray currentArray:(NSArray *)currentArray {
    XCTAssertEqual(expectedArray.count, currentArray.count);
    for (id obj in expectedArray) {
        XCTAssertTrue([currentArray containsObject:obj]);
    }
    for (id obj in currentArray) {
        XCTAssertTrue([expectedArray containsObject:obj]);
    }
}

@end
