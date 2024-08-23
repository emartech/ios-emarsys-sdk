//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

typedef void(^BindBlock)(sqlite3_stmt *statement);

@class EMSDBTriggerType;
@class EMSDBTriggerEvent;
@protocol EMSDBTriggerProtocol;
@protocol EMSModelMapperProtocol;

@protocol EMSSQLiteHelperProtocol <NSObject>

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

- (NSArray *)executeQuery:(NSString *)query
                   mapper:(id <EMSModelMapperProtocol>)mapper;

@end
