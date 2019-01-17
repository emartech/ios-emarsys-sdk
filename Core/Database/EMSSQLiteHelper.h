//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "EMSDBTrigger.h"

typedef void(^BindBlock)(sqlite3_stmt *statement);

@class EMSSQLiteHelper;
@protocol EMSModelMapperProtocol;
@protocol EMSDBTriggerProtocol;

@protocol EMSSQLiteHelperSchemaHandler

- (void)onCreateWithDbHelper:(EMSSQLiteHelper *)dbHelper;

- (void)onUpgradeWithDbHelper:(EMSSQLiteHelper *)dbHelper
                   oldVersion:(int)oldVersion
                   newVersion:(int)newVersion;

- (int)schemaVersion;

@end

@interface EMSSQLiteHelper : NSObject

@property(nonatomic, strong) id <EMSSQLiteHelperSchemaHandler> schemaHandler;
@property(nonatomic, readonly) NSDictionary *registeredTriggers;

- (instancetype)initWithDatabasePath:(NSString *)path
                      schemaDelegate:(id <EMSSQLiteHelperSchemaHandler>)schemaDelegate;

- (int)version;

- (void)open;

- (void)close;

- (void)registerTriggerWithTableName:(NSString *)tableName
                         triggerType:(EMSDBTriggerType *)triggerType
                        triggerEvent:(EMSDBTriggerEvent *)triggerEvent
                             trigger:(id <EMSDBTriggerProtocol>)trigger;

- (BOOL)removeFromTable:(NSString *)tableName
              selection:(NSString *)where
          selectionArgs:(NSArray<NSString *> *)whereArgs;

- (NSArray *)queryWithTable:(NSString *)tableName
                  selection:(NSString *)selection
              selectionArgs:(NSArray<NSString *> *)selectionArgs
                    orderBy:(NSString *)orderBy
                      limit:(NSString *)limit
                     mapper:(id <EMSModelMapperProtocol>)mapper;

- (BOOL)insertModel:(id)model
          withQuery:(NSString *)insertSQL
             mapper:(id <EMSModelMapperProtocol>)mapper;

- (BOOL)insertModel:(id)model
             mapper:(id <EMSModelMapperProtocol>)mapper;

- (BOOL)executeCommand:(NSString *)command;

- (BOOL)execute:(NSString *)command
  withBindBlock:(BindBlock)bindBlock;

- (NSArray *)executeQuery:(NSString *)query
                   mapper:(id <EMSModelMapperProtocol>)mapper;

@end