//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
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

@interface EMSTestColumnInfo : NSObject

@property(nonatomic, strong) NSString *columnName;
@property(nonatomic, strong) NSString *columnType;
@property(nonatomic, strong) NSString *defaultValue;
@property(nonatomic, assign) BOOL primaryKey;
@property(nonatomic, assign) BOOL notNull;

- (instancetype)initWithColumnName:(NSString *)columnName columnType:(NSString *)columnType;

- (instancetype)initWithColumnName:(NSString *)columnName
                        columnType:(NSString *)columnType
                      defaultValue:(NSString *)defaultValue
                        primaryKey:(BOOL)primaryKey
                           notNull:(BOOL)notNull;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToInfo:(EMSTestColumnInfo *)info;

- (NSUInteger)hash;

- (NSString *)description;
@end

@implementation EMSTestColumnInfo

- (instancetype)initWithColumnName:(NSString *)columnName columnType:(NSString *)columnType {
    if (self = [super init]) {
        _columnName = columnName;
        _columnType = columnType;
    }

    return self;
}

- (instancetype)initWithColumnName:(NSString *)columnName
                        columnType:(NSString *)columnType
                      defaultValue:(NSString *)defaultValue
                        primaryKey:(BOOL)primaryKey
                           notNull:(BOOL)notNull {
    if (self = [super init]) {
        _columnName = columnName;
        _columnType = columnType;
        _defaultValue = defaultValue;
        _primaryKey = primaryKey;
        _notNull = notNull;
    }

    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToInfo:other];
}

- (BOOL)isEqualToInfo:(EMSTestColumnInfo *)info {
    if (self == info)
        return YES;
    if (info == nil)
        return NO;
    if (self.columnName != info.columnName && ![self.columnName isEqualToString:info.columnName])
        return NO;
    if (self.columnType != info.columnType && ![self.columnType isEqualToString:info.columnType])
        return NO;
    if (self.defaultValue != info.defaultValue && ![self.defaultValue isEqualToString:info.defaultValue])
        return NO;
    if (self.primaryKey != info.primaryKey)
        return NO;
    if (self.notNull != info.notNull)
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.columnName hash];
    hash = hash * 31u + [self.columnType hash];
    hash = hash * 31u + [self.defaultValue hash];
    hash = hash * 31u + self.primaryKey;
    hash = hash * 31u + self.notNull;
    return hash;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.columnName=%@", self.columnName];
    [description appendFormat:@", self.columnType=%@", self.columnType];
    [description appendFormat:@", self.defaultValue=%@", self.defaultValue];
    [description appendFormat:@", self.primaryKey=%d", self.primaryKey];
    [description appendFormat:@", self.notNull=%d", self.notNull];
    [description appendString:@">"];
    return description;
}

@end


#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

SPEC_BEGIN(EMSSQLiteHelperTests)

        __block EMSSQLiteHelper *dbHelper;
        __block EMSSqliteSchemaHandler *schemaHandler;

        beforeEach(^{
            [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                       error:nil];
            schemaHandler = [[EMSSqliteSchemaHandler alloc] init];
            dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                      schemaDelegate:schemaHandler];
        });

        afterEach(^{
            [dbHelper close];
        });

        id (^requestModel)(NSString *url, NSDictionary *payload) = ^id(NSString *url, NSDictionary *payload) {
            return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodPOST];
                [builder setPayload:payload];
                [builder setHeaders:@{@"headerKey": @"headerValue"}];
            }                     timestampProvider:[EMSTimestampProvider new] uuidProvider:[EMSUUIDProvider new]];
        };

        void (^runCommandOnTestDB)(NSString *sql) = ^(NSString *sql) {
            sqlite3 *db;
            sqlite3_open([TEST_DB_PATH UTF8String], &db);
            sqlite3_stmt *statement;
            sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil);
            sqlite3_step(statement);
            sqlite3_close(db);
        };

        int (^columnIndexByName)(NSString *columnName, sqlite3_stmt *statement) = ^int(NSString *columnName, sqlite3_stmt *statement) {
            int columnIndex = -1;
            for (int i = 0; i < sqlite3_column_count(statement); i++) {
                NSString *currentColumnName = [NSString stringWithUTF8String:sqlite3_column_name(statement, i)];
                if ([currentColumnName isEqualToString:columnName]) {
                    columnIndex = i;
                    break;
                }
            }
            return columnIndex;
        };

        NSArray<EMSTestColumnInfo *> *(^tableSchemes)(NSString *tableName) = ^NSArray<EMSTestColumnInfo *> *(NSString *tableName) {
            NSMutableArray *result = [NSMutableArray array];
            sqlite3 *db;
            sqlite3_open([TEST_DB_PATH UTF8String], &db);
            sqlite3_stmt *statement;
            if (sqlite3_prepare_v2(db, [[NSString stringWithFormat:@"PRAGMA table_info(%@);",
                                                                   tableName] UTF8String], -1, &statement, nil) == SQLITE_OK) {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    NSString *columnName = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, columnIndexByName(@"name", statement))];
                    NSString *columnType = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, columnIndexByName(@"type", statement))];
                    int primaryKey = sqlite3_column_int(statement, columnIndexByName(@"pk", statement));
                    int notNull = sqlite3_column_int(statement, columnIndexByName(@"notnull", statement));
                    const unsigned char *defValue = sqlite3_column_text(statement, columnIndexByName(@"dflt_value", statement));
                    NSString *defaultValue;
                    if (defValue != nil) {
                        defaultValue = [NSString stringWithUTF8String:(const char *) defValue];
                    }
                    [result addObject:[[EMSTestColumnInfo alloc] initWithColumnName:columnName
                                                                         columnType:columnType
                                                                       defaultValue:defaultValue
                                                                         primaryKey:[@(primaryKey) boolValue]
                                                                            notNull:[@(notNull) boolValue]]];
                }
            } else {
                fail(@"sqlite3_prepare_v2 failed");
            };
            sqlite3_close(db);
            return result;
        };


        NSArray<NSString *> *(^indexedColumnsOfTable)(NSString *tableName) = ^NSArray<NSString *> *(NSString *tableName) {
            NSMutableArray *result = [NSMutableArray array];
            sqlite3 *db;
            sqlite3_open([TEST_DB_PATH UTF8String], &db);
            sqlite3_stmt *indexListStatement;
            if (sqlite3_prepare_v2(db, [[NSString stringWithFormat:@"PRAGMA index_list('%@');",
                                                                   tableName] UTF8String], -1, &indexListStatement, nil) == SQLITE_OK) {
                while (sqlite3_step(indexListStatement) == SQLITE_ROW) {
                    NSString *indexName = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(indexListStatement, columnIndexByName(@"name", indexListStatement))];
                    sqlite3_stmt *indexInfoStatement;
                    if (sqlite3_prepare_v2(db, [[NSString stringWithFormat:@"PRAGMA index_info('%@');",
                                                                           indexName] UTF8String], -1, &indexInfoStatement, nil) == SQLITE_OK) {
                        while (sqlite3_step(indexInfoStatement) == SQLITE_ROW) {
                            NSString *indexedColumnName = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(indexInfoStatement, columnIndexByName(@"name", indexInfoStatement))];
                            [result addObject:indexedColumnName];
                        }
                    } else {
                        fail(@"sqlite3_prepare_v2 failed");
                    };
                }
            } else {
                fail(@"sqlite3_prepare_v2 failed");
            };
            sqlite3_close(db);
            return result;
        };

        void (^initializeDbWithVersion)(int version) = ^(int version) {
            [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                       error:nil];
            sqlite3 *db;
            sqlite3_open([TEST_DB_PATH UTF8String], &db);
            dbHelper = [[EMSSQLiteHelper alloc] initWithSqlite3Db:db
                                                   schemaDelegate:schemaHandler];
            [schemaHandler onUpgradeWithDbHelper:dbHelper
                                      oldVersion:0
                                      newVersion:version];
        };

        void (^isEqualArrays)(NSArray *expectedArray, NSArray *currentArray) = ^(NSArray *expectedArray, NSArray *currentArray) {
            [[theValue(expectedArray.count == currentArray.count) should] beTrue];
            [[expectedArray should] containObjectsInArray:currentArray];
            [[currentArray should] containObjectsInArray:expectedArray];
        };

        describe(@"getVersion", ^{

            it(@"should return the latest version", ^{
                [dbHelper open];
                [[theValue([dbHelper version]) should] equal:@1];
            });

            it(@"should assert when version called in case of the db is not opened", ^{
                @try {
                    [dbHelper version];
                    fail(@"Expected exception when calling version in case the db is not opened");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }

            });

        });

        describe(@"open", ^{

            it(@"should call onCreate when the database is opened the first time", ^{
                EMSSqliteSchemaHandler *schemaDelegate = [EMSSqliteSchemaHandler mock];
                dbHelper.schemaHandler = schemaDelegate;
                [[schemaDelegate should] receive:@selector(onCreateWithDbHelper:) withArguments:kw_any()];

                [dbHelper open];
            });

            it(@"should call onUpgrade when the oldVersion and newVersion are different", ^{
                runCommandOnTestDB(@"PRAGMA user_version=2;");

                EMSSqliteSchemaHandler *schemaDelegate = [EMSSqliteSchemaHandler mock];
                dbHelper.schemaHandler = schemaDelegate;
                [[schemaDelegate should] receive:@selector(schemaVersion) andReturn:theValue(100)];
                [[schemaDelegate should] receive:@selector(onUpgradeWithDbHelper:oldVersion:newVersion:)
                                   withArguments:kw_any(), theValue(2), theValue(100)];

                [dbHelper open];
            });

        });

        describe(@"executeCommand", ^{

            it(@"should return YES when successfully executeCommand on DB", ^{
                [dbHelper open];
                BOOL returnedValue = [dbHelper executeCommand:@"PRAGMA user_version=42;"];
                [dbHelper close];

                sqlite3 *db;
                sqlite3_open([TEST_DB_PATH UTF8String], &db);
                sqlite3_stmt *statement;
                if (sqlite3_prepare_v2(db, [@"PRAGMA user_version;" UTF8String], -1, &statement, nil) == SQLITE_OK) {
                    if (sqlite3_step(statement) == SQLITE_ROW) {
                        [[theValue(returnedValue) should] beTrue];
                        [[theValue(sqlite3_column_int(statement, 0)) should] equal:@42];
                    } else {
                        fail(@"sqlite3_step failed");
                    }
                } else {
                    fail(@"sqlite3_prepare_v2 failed");
                };
                sqlite3_close(db);

            });

            it(@"should return NO when executeCommand failed", ^{
                [dbHelper open];
                BOOL returnedValue = [dbHelper executeCommand:@"invalid sql;"];
                [[theValue(returnedValue) should] beFalse];
            });

        });

        describe(@"remove:fromTable:where:whereArgs:", ^{
            it(@"should remove every rows when called with no where", ^{
                EMSSqliteSchemaHandler *schemaDelegate = [EMSSqliteSchemaHandler new];
                [dbHelper setSchemaHandler:schemaDelegate];
                [dbHelper open];
                EMSShard *model = [[EMSShard alloc] initWithShardId:@"id"
                                                               type:@"type"
                                                               data:@{}
                                                          timestamp:[NSDate date]
                                                                ttl:200.];
                EMSShardMapper *mapper = [EMSShardMapper new];

                [dbHelper insertModel:model mapper:mapper];
                [dbHelper insertModel:model mapper:mapper];
                [dbHelper removeFromTable:[mapper tableName]
                                selection:nil
                            selectionArgs:nil];

                NSArray *result = [dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:mapper];
                [[result should] beEmpty];
            });

            it(@"should remove every rows that matches to the where parameters", ^{
                EMSSqliteSchemaHandler *schemaDelegate = [EMSSqliteSchemaHandler new];
                [dbHelper setSchemaHandler:schemaDelegate];
                [dbHelper open];
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

                NSArray *result = [dbHelper executeQuery:SQL_SHARD_SELECTALL mapper:mapper];

                [[result should] contain:model2];
                [[result shouldNot] contain:model];
                [[theValue([result count]) should] equal:theValue(1)];
            });

            it(@"should remove every rows that matches to the where parameters", ^{
                EMSSqliteSchemaHandler *schemaDelegate = [EMSSqliteSchemaHandler new];
                [dbHelper setSchemaHandler:schemaDelegate];
                [dbHelper open];
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
                            selectionArgs:@[@"type", @"300"]];

                NSArray *result = [dbHelper executeQuery:SQL_SHARD_SELECTALL
                                                  mapper:mapper];

                [[result should] contain:model2];
                [[result should] contain:model];
                [[theValue([result count]) should] equal:theValue(2)];
            });
        });

        describe(@"queryWithTable:selection:selectionArgs:orderBy:limit:mapper:", ^{
            it(@"tableName should not be nil", ^{
                EMSShardMapper *mapper = [EMSShardMapper new];

                @try {
                    [dbHelper queryWithTable:nil
                                   selection:@"selection"
                               selectionArgs:@[@"args"]
                                     orderBy:@"order by"
                                       limit:@"1"
                                      mapper:mapper];

                    fail(@"Expected exception when tableName is nil");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: tableName"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"mapper should not be nil", ^{

                @try {
                    [dbHelper queryWithTable:@"tableName"
                                   selection:@"selection"
                               selectionArgs:nil
                                     orderBy:nil
                                       limit:nil
                                      mapper:nil];

                    fail(@"Expected exception when mapper is nil");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: mapper"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should query all item", ^{
                EMSSqliteSchemaHandler *schemaDelegate = [EMSSqliteSchemaHandler new];
                [dbHelper setSchemaHandler:schemaDelegate];
                [dbHelper open];
                EMSShard *model = [[EMSShard alloc] initWithShardId:@"id"
                                                               type:@"type"
                                                               data:@{}
                                                          timestamp:[NSDate date]
                                                                ttl:200.];
                NSArray *expectedResult = @[model, model];

                EMSShardMapper *mapper = [EMSShardMapper new];

                [dbHelper insertModel:model
                               mapper:mapper];
                [dbHelper insertModel:model
                               mapper:mapper];

                NSArray *result = [dbHelper queryWithTable:mapper.tableName
                                                 selection:nil
                                             selectionArgs:nil
                                                   orderBy:nil
                                                     limit:nil
                                                    mapper:mapper];
                [[result should] equal:expectedResult];
            });

            it(@"should query the expected type", ^{
                EMSSqliteSchemaHandler *schemaDelegate = [EMSSqliteSchemaHandler new];
                [dbHelper setSchemaHandler:schemaDelegate];
                [dbHelper open];
                EMSShard *model = [[EMSShard alloc] initWithShardId:@"id"
                                                               type:@"type"
                                                               data:@{}
                                                          timestamp:[NSDate date]
                                                                ttl:200.];
                EMSShard *model2 = [[EMSShard alloc] initWithShardId:@"id2"
                                                                type:@"shard"
                                                                data:@{}
                                                           timestamp:[NSDate date]
                                                                 ttl:200.];
                NSArray *expectedResult = @[model2];

                EMSShardMapper *mapper = [EMSShardMapper new];

                [dbHelper insertModel:model
                               mapper:mapper];
                [dbHelper insertModel:model2
                               mapper:mapper];

                NSArray *result = [dbHelper queryWithTable:mapper.tableName
                                                 selection:@"type LIKE ?"
                                             selectionArgs:@[@"shard"]
                                                   orderBy:nil
                                                     limit:nil
                                                    mapper:mapper];
                [[result should] equal:expectedResult];
            });
            it(@"should query the expected count", ^{
                EMSSqliteSchemaHandler *schemaDelegate = [EMSSqliteSchemaHandler new];
                [dbHelper setSchemaHandler:schemaDelegate];
                [dbHelper open];

                EMSRequestModel *model = requestModel(@"https://www.google.com", @{
                    @"key": @"value"
                });
                EMSRequestModel *model2 = requestModel(@"https://www.google.com", @{
                    @"key": @"value"
                });

                NSArray *expectedResult = @[model];

                EMSRequestModelMapper *mapper = [EMSRequestModelMapper new];

                [dbHelper insertModel:model
                               mapper:mapper];
                [dbHelper insertModel:model2
                               mapper:mapper];

                EMSQueryOldestRowSpecification *queryByType = [[EMSQueryOldestRowSpecification alloc] init];

                NSArray *result = [dbHelper queryWithTable:mapper.tableName
                                                 selection:nil
                                             selectionArgs:nil
                                                   orderBy:@"ROWID ASC"
                                                     limit:@"1"
                                                    mapper:mapper];
                [[result should] equal:expectedResult];
            });

        });

        describe(@"insertModel:withQuery:mapper:", ^{
            it(@"should insert the correct model in the database", ^{
                EMSSqliteSchemaHandler *schemaDelegate = [EMSSqliteSchemaHandler new];
                [dbHelper setSchemaHandler:schemaDelegate];
                [dbHelper open];
                EMSRequestModel *model = requestModel(@"https://www.google.com", @{
                    @"key": @"value"
                });
                EMSRequestModelMapper *mapper = [EMSRequestModelMapper new];

                BOOL returnedValue = [dbHelper insertModel:model
                                                 withQuery:SQL_REQUEST_INSERT
                                                    mapper:mapper];
                NSArray *requests = [dbHelper executeQuery:SQL_REQUEST_SELECTFIRST
                                                    mapper:mapper];
                EMSRequestModel *request = [requests firstObject];
                [[theValue(returnedValue) should] beTrue];
                [[model should] equal:request];
            });
        });

        describe(@"insertModel:mapper:", ^{

            it(@"should insert the correct model in the database", ^{
                EMSSqliteSchemaHandler *schemaDelegate = [EMSSqliteSchemaHandler new];
                [dbHelper setSchemaHandler:schemaDelegate];
                [dbHelper open];
                EMSRequestModel *model = requestModel(@"https://www.google.com", @{
                    @"key": @"value"
                });
                EMSRequestModelMapper *mapper = [EMSRequestModelMapper new];

                BOOL returnedValue = [dbHelper insertModel:model
                                                    mapper:mapper];
                NSArray *requests = [dbHelper executeQuery:SQL_REQUEST_SELECTFIRST
                                                    mapper:mapper];
                EMSRequestModel *request = [requests firstObject];
                [[theValue(returnedValue) should] beTrue];
                [[model should] equal:request];
            });

            it(@"should insert the correct model in the database", ^{
                EMSSqliteSchemaHandler *schemaDelegate = [EMSSqliteSchemaHandler new];
                [dbHelper setSchemaHandler:schemaDelegate];
                [dbHelper open];
                EMSShard *model = [[EMSShard alloc] initWithShardId:@"id"
                                                               type:@"type"
                                                               data:@{}
                                                          timestamp:[NSDate date]
                                                                ttl:200.];
                EMSShardMapper *mapper = [EMSShardMapper new];

                BOOL returnedValue = [dbHelper insertModel:model
                                                    mapper:mapper];
                NSArray *shards = [dbHelper executeQuery:SQL_SHARD_SELECTALL
                                                  mapper:mapper];
                EMSShard *expectedShard = [shards lastObject];
                [[theValue(returnedValue) should] beTrue];
                [[model should] equal:expectedShard];
            });
        });

        describe(@"schemaHandler onCreate", ^{

            it(@"should initialize the database with version three", ^{
                initializeDbWithVersion(1);

                NSArray<EMSTestColumnInfo *> *expectedRequestColumnInfos = tableSchemes(@"request");
                NSArray<EMSTestColumnInfo *> *expectedShardColumnInfos = tableSchemes(@"shard");
                [dbHelper close];

                [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                           error:nil];
                sqlite3 *db;
                sqlite3_open([TEST_DB_PATH UTF8String], &db);
                dbHelper = [[EMSSQLiteHelper alloc] initWithSqlite3Db:db
                                                       schemaDelegate:schemaHandler];
                [schemaHandler onCreateWithDbHelper:dbHelper];

                NSArray<EMSTestColumnInfo *> *currentRequestColumnInfos = tableSchemes(@"request");
                NSArray<EMSTestColumnInfo *> *currentShardColumnInfos = tableSchemes(@"shard");

                isEqualArrays(expectedRequestColumnInfos, currentRequestColumnInfos);
                isEqualArrays(expectedShardColumnInfos, currentShardColumnInfos);

                [[theValue([dbHelper version]) should] equal:@1];
            });

        });

        describe(@"schema migration", ^{

            it(@"should update from 0 to 1 by adding Request table to database", ^{
                initializeDbWithVersion(0);

                NSArray<EMSTestColumnInfo *> *expectedRequestColumnInfos = @[
                    [[EMSTestColumnInfo alloc] initWithColumnName:@"request_id"
                                                       columnType:@"TEXT"],
                    [[EMSTestColumnInfo alloc] initWithColumnName:@"method"
                                                       columnType:@"TEXT"],
                    [[EMSTestColumnInfo alloc] initWithColumnName:@"url"
                                                       columnType:@"TEXT"],
                    [[EMSTestColumnInfo alloc] initWithColumnName:@"headers"
                                                       columnType:@"BLOB"],
                    [[EMSTestColumnInfo alloc] initWithColumnName:@"payload"
                                                       columnType:@"BLOB"],
                    [[EMSTestColumnInfo alloc] initWithColumnName:@"timestamp"
                                                       columnType:@"REAL"],
                    [[EMSTestColumnInfo alloc] initWithColumnName:@"expiry"
                                                       columnType:@"DOUBLE"
                                                     defaultValue:[NSString stringWithFormat:@"%f", DEFAULT_REQUESTMODEL_EXPIRY]
                                                       primaryKey:false
                                                          notNull:false]
                ];
                NSArray<EMSTestColumnInfo *> *expectedShardColumnInfos = @[
                    [[EMSTestColumnInfo alloc] initWithColumnName:@"shard_id"
                                                       columnType:@"TEXT"],
                    [[EMSTestColumnInfo alloc] initWithColumnName:@"type"
                                                       columnType:@"TEXT"],
                    [[EMSTestColumnInfo alloc] initWithColumnName:@"data"
                                                       columnType:@"BLOB"],
                    [[EMSTestColumnInfo alloc] initWithColumnName:@"timestamp"
                                                       columnType:@"REAL"],
                    [[EMSTestColumnInfo alloc] initWithColumnName:@"ttl"
                                                       columnType:@"REAL"]
                ];

                [schemaHandler onUpgradeWithDbHelper:dbHelper
                                          oldVersion:0
                                          newVersion:1];

                NSArray<EMSTestColumnInfo *> *currentRequestColumnInfos = tableSchemes(@"request");
                NSArray<EMSTestColumnInfo *> *currentShardColumnInfos = tableSchemes(@"shard");

                isEqualArrays(expectedRequestColumnInfos, currentRequestColumnInfos);
                isEqualArrays(expectedShardColumnInfos, currentShardColumnInfos);

                NSArray<NSString *> *indexedRequestColumns = indexedColumnsOfTable(@"request");
                [[indexedRequestColumns should] beEmpty];

                NSArray<NSString *> *indexedShardColumns = indexedColumnsOfTable(@"shard");

                [[theValue(indexedShardColumns.count) should] equal:theValue(2)];
                [[indexedShardColumns should] contain:@"shard_id"];
                [[indexedShardColumns should] contain:@"type"];

                [[theValue([dbHelper version]) should] equal:@1];
            });

        });

SPEC_END
