//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSSQLiteHelper.h"

@interface EMSSQLiteHelper (Test)

- (instancetype)initWithSqlite3Db:(sqlite3 *)db
                   schemaDelegate:(id <EMSSQLiteHelperSchemaHandler>)schemaDelegate;
@end