//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSQLiteHelper.h"
#import "EMSModelMapperProtocol.h"
#import "EMSDBTriggerKey.h"
#import "EMSSQLStatementFactory.h"
#import "EMSDBTriggerProtocol.h"

@interface EMSSQLiteHelper ()

@property(nonatomic, assign) sqlite3 *db;
@property(nonatomic, strong) NSString *dbPath;
@property(nonatomic, strong) NSMutableDictionary *triggers;

@end

@implementation EMSSQLiteHelper

- (instancetype)initWithDatabasePath:(NSString *)path
                      schemaDelegate:(id <EMSSQLiteHelperSchemaHandler>)schemaDelegate {
    if (self = [super init]) {
        _dbPath = path;
        _schemaHandler = schemaDelegate;
        _triggers = [NSMutableDictionary new];
    }

    return self;
}

- (instancetype)initWithSqlite3Db:(sqlite3 *)db
                   schemaDelegate:(id <EMSSQLiteHelperSchemaHandler>)schemaDelegate {
    if (self = [super init]) {
        _db = db;
        _schemaHandler = schemaDelegate;
        _triggers = [NSMutableDictionary new];
    }
    return self;
}

- (int)version {
    NSParameterAssert(_db);

    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_db, [@"PRAGMA user_version;" UTF8String], -1, &statement, nil);
    if (result == SQLITE_OK) {
        int version = 0;
        int step = sqlite3_step(statement);
        if (step == SQLITE_ROW) {
            version = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
        return version;
    } else {
        return -1;
    };
}

- (void)open {
    if (sqlite3_open([self.dbPath UTF8String], &_db) == SQLITE_OK) {

        int version = [self version];
        if (version == 0) {
            [self.schemaHandler onCreateWithDbHelper:self];
        } else {
            int newVersion = [self.schemaHandler schemaVersion];
            if (version < newVersion) {
                [self.schemaHandler onUpgradeWithDbHelper:self
                                               oldVersion:version
                                               newVersion:newVersion];
            }
        }
    }
}

- (void)close {
    sqlite3_close(_db);
    _db = nil;
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
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, [command UTF8String], -1, &statement, nil) == SQLITE_OK) {
        int value = sqlite3_step(statement);
        sqlite3_finalize(statement);
        return value == SQLITE_ROW || value == SQLITE_DONE;
    }
    return NO;
}

- (BOOL)execute:(NSString *)command withBindBlock:(BindBlock)bindBlock {
    sqlite3_stmt *statement;
    int i = sqlite3_prepare_v2(_db, [command UTF8String], -1, &statement, nil);
    if (i == SQLITE_OK) {
        bindBlock(statement);
        int value = sqlite3_step(statement);
        sqlite3_finalize(statement);
        return value == SQLITE_ROW || value == SQLITE_DONE;
    }
    return NO;
}

- (BOOL)removeFromTable:(NSString *)tableName
              selection:(NSString *)where
          selectionArgs:(NSArray<NSString *> *)whereArgs {
    NSString *sqlCommand;
    if (where == nil || [where isEqualToString:@""]) {
        sqlCommand = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    } else {
        sqlCommand = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", tableName, where];
    }


    [self runTriggerWithTableName:tableName
                            event:[EMSDBTriggerEvent deleteEvent]
                             type:[EMSDBTriggerType beforeType]];

    BOOL result = [self execute:sqlCommand
                  withBindBlock:^(sqlite3_stmt *statement) {
                      for (int i = 0; i < whereArgs.count; ++i) {
                          sqlite3_bind_text(statement, i + 1, [whereArgs[(NSUInteger) i] UTF8String], -1, SQLITE_TRANSIENT);
                      }
                  }];

    [self runTriggerWithTableName:tableName
                            event:[EMSDBTriggerEvent deleteEvent]
                             type:[EMSDBTriggerType afterType]];

    return result;
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
    NSMutableArray *models = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (selectionArgs && selectionArgs.count > 0) {
            for (int i = 0; i < selectionArgs.count; ++i) {
                sqlite3_bind_text(statement, i + 1, [selectionArgs[(NSUInteger) i] UTF8String], -1, SQLITE_TRANSIENT);
            }
        }
        while (sqlite3_step(statement) == SQLITE_ROW) {
            [models addObject:[mapper modelFromStatement:statement]];
        }
        sqlite3_finalize(statement);
    }

    return [NSArray arrayWithArray:models];
}

- (BOOL)insertModel:(id)model
          withQuery:(NSString *)insertSQL
             mapper:(id <EMSModelMapperProtocol>)mapper {
    return [self execute:insertSQL
           withBindBlock:^(sqlite3_stmt *statement) {
               [mapper bindStatement:statement
                           fromModel:model];
           }];
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
    NSMutableArray *models = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            [models addObject:[mapper modelFromStatement:statement]];
        }
        sqlite3_finalize(statement);
        return [NSArray arrayWithArray:models];
    }
    return nil;
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

@end
