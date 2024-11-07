//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSQLiteHelper.h"
#import "EMSModelMapperProtocol.h"
#import "EMSDBTriggerKey.h"
#import "EMSSQLStatementFactory.h"
#import "EMSDBTriggerProtocol.h"
#import "EMSSQLiteHelperSchemaHandlerProtocol.h"
#import "EMSStatusLog.h"
#import "EMSMacros.h"
#import "NSOperationQueue+EMSCore.h"

typedef BOOL (^EMSSQLLiteTransactionBlock)(void);

const char *kBeginTransactionSQL = "BEGIN TRANSACTION;";
const char *kCommitTransactionSQL = "COMMIT;";
const char *kRollbackTransactionSQL = "ROLLBACK;";

@interface EMSSQLiteHelper ()

@property(nonatomic, assign) sqlite3 *db;
@property(nonatomic, strong) NSString *dbPath;
@property(nonatomic, strong) NSMutableDictionary *triggers;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

- (BOOL)executeTransaction:(EMSSQLLiteTransactionBlock)transactionBlock;
- (void)beginTransaction;
- (void)commitTransaction;
- (void)rollbackTransaction;
- (void)logWithSel:(SEL)sel
         sqlResult:(int)sqlResult
             error:(nullable NSString *)error
               sql:(NSString *)sql;

@end

@implementation EMSSQLiteHelper

- (instancetype)initWithDatabasePath:(NSString *)path
                      schemaDelegate:(id <EMSSQLiteHelperSchemaHandlerProtocol>)schemaDelegate
                      operationQueue:(NSOperationQueue *)operationQueue {
    if (self = [super init]) {
        _dbPath = path;
        _schemaHandler = schemaDelegate;
        _triggers = [NSMutableDictionary new];
        _operationQueue = operationQueue;
    }

    return self;
}

- (instancetype)initWithSqlite3Db:(sqlite3 *)db
                   schemaDelegate:(id <EMSSQLiteHelperSchemaHandlerProtocol>)schemaDelegate
                   operationQueue:(NSOperationQueue *)operationQueue {
    if (self = [super init]) {
        _db = db;
        _schemaHandler = schemaDelegate;
        _triggers = [NSMutableDictionary new];
        _operationQueue = operationQueue;
    }
    return self;
}

- (int)version {
    NSParameterAssert(_db);
    __block int version = 0;
    __weak typeof(self) weakSelf = self;
    [weakSelf executeTransaction:^BOOL{
        sqlite3_stmt *statement;
        int result = sqlite3_prepare_v2(weakSelf.db, [@"PRAGMA user_version;" UTF8String], -1, &statement, nil);
        if (result == SQLITE_OK) {
            int step = sqlite3_step(statement);
            if (step == SQLITE_ROW) {
                version = sqlite3_column_int(statement, 0);
            }
        }
        sqlite3_finalize(statement);
        return version > 0;
    }];
    return version;
}

- (void)open {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        sqlite3_initialize();
        int sqlResult = sqlite3_open_v2([weakSelf.dbPath UTF8String], &self->_db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL);
        if (sqlResult == SQLITE_OK) {
            int version = [weakSelf version];
            if (version == 0) {
                [weakSelf.schemaHandler onCreateWithDbHelper:weakSelf];
            } else {
                int newVersion = [weakSelf.schemaHandler schemaVersion];
                if (version < newVersion) {
                    [self.schemaHandler onUpgradeWithDbHelper:weakSelf
                                                   oldVersion:version
                                                   newVersion:newVersion];
                }
            }
        }
    }];
}

- (void)close {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        sqlite3_close_v2(weakSelf.db);
        sqlite3_shutdown();
    }];
}

- (void)registerTriggerWithTableName:(NSString *)tableName
                         triggerType:(EMSDBTriggerType *)triggerType
                        triggerEvent:(EMSDBTriggerEvent *)triggerEvent
                             trigger:(id <EMSDBTriggerProtocol>)trigger {
    EMSDBTriggerKey *triggerKey = [[EMSDBTriggerKey alloc] initWithTableName:tableName
                                                                   withEvent:triggerEvent
                                                                    withType:triggerType];
    NSMutableArray *actions = self.triggers[triggerKey];
    if (actions == nil) {
        actions = [NSMutableArray new];
        self.triggers[triggerKey] = actions;
    }
    [actions addObject:trigger];
}

- (BOOL)executeCommand:(NSString *)command {
    __weak typeof(self) weakSelf = self;
    return [self executeTransaction:^BOOL{
        BOOL result = YES;
        char *utf8Error;
        int sqlResult = sqlite3_exec(weakSelf.db, [command UTF8String], NULL, NULL, &utf8Error);
        if (sqlResult != SQLITE_OK) {
            result = NO;
            NSString *error = nil;
            if (error != NULL) {
                error = [NSString stringWithUTF8String:utf8Error];
            }
            [self logWithSel:_cmd
                   sqlResult:sqlResult
                       error:error
                         sql:[NSString stringWithUTF8String:kCommitTransactionSQL]];
        }
        return result;
    }];
}

- (BOOL)removeFromTable:(NSString *)tableName
              selection:(NSString *)where
          selectionArgs:(NSArray<NSString *> *)whereArgs {
    NSString *sql;
    if (where == nil || [where isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"DELETE FROM %@",
                                                tableName];
    } else {
        sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",
                                                tableName,
                                                where];
    }

    [self runTriggerWithTableName:tableName
                            event:[EMSDBTriggerEvent deleteEvent]
                             type:[EMSDBTriggerType beforeType]];
    
    __block BOOL success;
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        success = [weakSelf executeTransaction:^BOOL{
            BOOL result = YES;
            sqlite3_stmt *statement;
            int prepareResult = sqlite3_prepare_v2(weakSelf.db, [sql UTF8String], -1, &statement, NULL);
            if (prepareResult == SQLITE_OK) {
                if (whereArgs.count > 0) {
                    for (int i = 0; i < whereArgs.count; ++i) {
                        sqlite3_bind_text(statement, i + 1, [whereArgs[(NSUInteger) i] UTF8String], -1, SQLITE_TRANSIENT);
                    }
                }
                int stepResult = sqlite3_step(statement);
                if (stepResult != SQLITE_DONE) {
                    result = NO;
                    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                    parameters[@"sql"] = sql;
                    parameters[@"stepResult"] = @(stepResult);
                    EMSLog([[EMSStatusLog alloc] initWithClass:[weakSelf class]
                                                           sel:@selector(removeFromTable:selection:selectionArgs:)
                                                    parameters:parameters
                                                        status:nil], LogLevelError);
                }
            } else {
                result = NO;
                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                parameters[@"sql"] = sql;
                parameters[@"prepareResult"] = @(prepareResult);
                EMSLog([[EMSStatusLog alloc] initWithClass:[weakSelf class]
                                                       sel:@selector(removeFromTable:selection:selectionArgs:)
                                                parameters:parameters
                                                    status:nil], LogLevelError);
            }
            sqlite3_finalize(statement);
            return result;
        }];
    }];

    [self runTriggerWithTableName:tableName
                            event:[EMSDBTriggerEvent deleteEvent]
                             type:[EMSDBTriggerType afterType]];
    return success;
}

- (NSArray *)queryWithTable:(NSString *)tableName
                  selection:(NSString *)selection
              selectionArgs:(NSArray<NSString *> *)selectionArgs
                    orderBy:(NSString *)orderBy
                      limit:(NSString *)limit
                     mapper:(id <EMSModelMapperProtocol>)mapper {
    NSParameterAssert(tableName);
    NSParameterAssert(mapper);
    NSString *sql = [EMSSQLStatementFactory createQueryStatementWithTableName:tableName
                                                                    selection:selection
                                                                      orderBy:orderBy
                                                                        limit:limit];
    __block NSMutableArray *models = [NSMutableArray new];
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [weakSelf executeTransaction:^BOOL{
            BOOL result = YES;
            sqlite3_stmt *statement;
            int prepareResult = sqlite3_prepare_v2(weakSelf.db, [sql UTF8String], -1, &statement, NULL);
            if (prepareResult == SQLITE_OK) {
                if (selectionArgs && selectionArgs.count > 0) {
                    for (int i = 0; i < selectionArgs.count; ++i) {
                        sqlite3_bind_text(statement, i + 1, [selectionArgs[(NSUInteger) i] UTF8String], -1, SQLITE_TRANSIENT);
                    }
                }
                int stepResult;
                do {
                    stepResult = sqlite3_step(statement);
                    if (stepResult == SQLITE_ROW) {
                        [models addObject:[mapper modelFromStatement:statement]];
                    } else if (stepResult != SQLITE_DONE) {
                        result = NO;
                        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                        parameters[@"sql"] = sql;
                        parameters[@"stepResult"] = @(stepResult);
                        EMSLog([[EMSStatusLog alloc] initWithClass:[weakSelf class]
                                                               sel:@selector(queryWithTable:selection:selectionArgs:orderBy:limit:mapper:)
                                                        parameters:parameters
                                                            status:nil], LogLevelError);
                    }
                } while (stepResult == SQLITE_ROW);
            } else {
                result = NO;
                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                parameters[@"sql"] = sql;
                parameters[@"prepareResult"] = @(prepareResult);
                EMSLog([[EMSStatusLog alloc] initWithClass:[weakSelf class]
                                                       sel:@selector(queryWithTable:selection:selectionArgs:orderBy:limit:mapper:)
                                                parameters:parameters
                                                    status:nil], LogLevelError);
            }
            sqlite3_finalize(statement);
            return result;
        }];
    }];
    return [NSArray arrayWithArray:models];
}

- (BOOL)insertModel:(id)model
          withQuery:(NSString *)insertSQL
             mapper:(id <EMSModelMapperProtocol>)mapper {
    __block BOOL success;
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        success = [weakSelf executeTransaction:^BOOL{
            BOOL result = YES;
            sqlite3_stmt *statement;
            int prepareResult = sqlite3_prepare_v2(weakSelf.db, [insertSQL UTF8String], -1, &statement, NULL);
            if (prepareResult == SQLITE_OK) {
                [mapper bindStatement:statement
                            fromModel:model];
                int stepResult = sqlite3_step(statement);
                if (stepResult != SQLITE_DONE && stepResult != SQLITE_FULL) {
                    result = NO;
                    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                    parameters[@"sql"] = insertSQL;
                    parameters[@"model"] = [model  description];
                    parameters[@"stepResult"] = @(stepResult);
                    EMSLog([[EMSStatusLog alloc] initWithClass:[weakSelf class]
                                                           sel:@selector(insertModel:withQuery:mapper:)
                                                    parameters:parameters
                                                        status:nil], LogLevelError);
                }
            } else {
                result = NO;
                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                parameters[@"sql"] = insertSQL;
                parameters[@"model"] = [model  description];
                parameters[@"prepareResult"] = @(prepareResult);
                EMSLog([[EMSStatusLog alloc] initWithClass:[weakSelf class]
                                                       sel:@selector(insertModel:withQuery:mapper:)
                                                parameters:parameters
                                                    status:nil], LogLevelError);
            }
            sqlite3_finalize(statement);
            return result;
        }];
    }];
    return success;
}

- (BOOL)insertModel:(id)model
             mapper:(id <EMSModelMapperProtocol>)mapper {
    [self runTriggerWithTableName:[mapper tableName]
                            event:[EMSDBTriggerEvent insertEvent]
                             type:[EMSDBTriggerType beforeType]];

    BOOL result = [self insertModel:model
                          withQuery:[self createInsertSql:mapper]
                             mapper:mapper];


    [self runTriggerWithTableName:[mapper tableName]
                            event:[EMSDBTriggerEvent insertEvent]
                             type:[EMSDBTriggerType afterType]];

    return result;
}

- (NSArray *)executeQuery:(NSString *)query
                   mapper:(id <EMSModelMapperProtocol>)mapper {
    __block NSMutableArray *models = [NSMutableArray new];
    __weak typeof(self) weakSelf = self;
    [self.operationQueue runSynchronized:^{
        [weakSelf executeTransaction:^BOOL{
            BOOL result = YES;
            sqlite3_stmt *statement;
            int prepareResult = sqlite3_prepare_v2(weakSelf.db, [query UTF8String], -1, &statement, NULL);
            if (prepareResult == SQLITE_OK) {
                int stepResult;
                do {
                    stepResult = sqlite3_step(statement);
                    if (stepResult == SQLITE_ROW) {
                        [models addObject:[mapper modelFromStatement:statement]];
                    } else if (stepResult != SQLITE_DONE) {
                        result = NO;
                        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                        parameters[@"sql"] = query;
                        parameters[@"stepResult"] = @(stepResult);
                        EMSLog([[EMSStatusLog alloc] initWithClass:[weakSelf class]
                                                               sel:@selector(executeQuery:mapper:)
                                                        parameters:parameters
                                                            status:nil], LogLevelError);
                    }
                } while (stepResult == SQLITE_ROW);
            } else {
                result = NO;
                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                parameters[@"sql"] = query;
                parameters[@"prepareResult"] = @(prepareResult);
                EMSLog([[EMSStatusLog alloc] initWithClass:[weakSelf class]
                                                       sel:@selector(executeQuery:mapper:)
                                                parameters:parameters
                                                    status:nil], LogLevelError);
            }
            sqlite3_finalize(statement);
            return result;
        }];
    }];
    return [NSArray arrayWithArray:models];
}

- (NSString *)createInsertSql:(id <EMSModelMapperProtocol>)mapper {
    NSMutableString *placeholderString = [NSMutableString new];
    for (int i = 0; i < [mapper fieldCount]; ++i) {
        [placeholderString appendString:@"?"];
        if (i < [mapper fieldCount] - 1) {
            [placeholderString appendString:@","];
        }
    }

    NSString *sqlQuery = [NSString stringWithFormat:@"INSERT INTO %@ VALUES (%@)",
                                                    [mapper tableName],
                                                    placeholderString];
    return sqlQuery;
}

- (void)runTriggerWithTableName:(NSString *)tableName
                          event:(EMSDBTriggerEvent *)event
                           type:(EMSDBTriggerType *)type {

    EMSDBTriggerKey *key = [[EMSDBTriggerKey alloc] initWithTableName:tableName
                                                            withEvent:event
                                                             withType:type];
    NSMutableArray *actions = self.triggers[key];
    for (id <EMSDBTriggerProtocol> action in actions) {
        [action trigger];
    }
}

- (NSDictionary *)registeredTriggers {
    return [NSDictionary dictionaryWithDictionary:self.triggers];
}

- (BOOL)executeTransaction:(EMSSQLLiteTransactionBlock)transactionBlock {
    [self beginTransaction];
    BOOL success = transactionBlock();
    if (success) {
        [self commitTransaction];
    } else {
        [self rollbackTransaction];
    }
    return success;
}

- (void)beginTransaction {
    char *utf8Error;
    int execResult = sqlite3_exec(self.db, kBeginTransactionSQL, NULL, NULL, &utf8Error);
    if (execResult != SQLITE_OK) {
        NSString *error = nil;
        if (error != NULL) {
            error = [NSString stringWithUTF8String:utf8Error];
        }
        [self logWithSel:_cmd
               sqlResult:execResult
                   error:error
                     sql:[NSString stringWithUTF8String:kBeginTransactionSQL]];
    }
}

- (void)commitTransaction {
    char *utf8Error;
    int execResult = sqlite3_exec(self.db, kCommitTransactionSQL, NULL, NULL, &utf8Error);
    if (execResult != SQLITE_OK) {
        NSString *error = nil;
        if (error != NULL) {
            error = [NSString stringWithUTF8String:utf8Error];
        }
        [self logWithSel:_cmd
               sqlResult:execResult
                   error:error
                     sql:[NSString stringWithUTF8String:kCommitTransactionSQL]];
    }
}

- (void)rollbackTransaction {
    char *utf8Error;
    int execResult = sqlite3_exec(self.db, kRollbackTransactionSQL, NULL, NULL, &utf8Error);
    if (execResult != SQLITE_OK) {
        NSString *error = nil;
        if (error != NULL) {
            error = [NSString stringWithUTF8String:utf8Error];
        }
        [self logWithSel:_cmd
               sqlResult:execResult
                   error:error
                     sql:[NSString stringWithUTF8String:kRollbackTransactionSQL]];
    }
}

- (void)logWithSel:(SEL)sel
         sqlResult:(int)sqlResult
             error:(nullable NSString *)error
               sql:(NSString *)sql {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"sql"] = sql;
    parameters[@"sqlResult"] = @(sqlResult);
    parameters[@"error"] = error;
    EMSLog([[EMSStatusLog alloc] initWithClass:[self class]
                                           sel:sel
                                    parameters:parameters
                                        status:nil], LogLevelError);
}

@end
