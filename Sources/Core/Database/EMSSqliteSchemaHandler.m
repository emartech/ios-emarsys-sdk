//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSqliteSchemaHandler.h"
#import "EMSSchemaContract.h"

@implementation EMSSqliteSchemaHandler

- (void)onCreateWithDbHelper:(EMSSQLiteHelper *)dbHelper {
    [self onUpgradeWithDbHelper:dbHelper
                     oldVersion:0
                     newVersion:[self schemaVersion]];
}

- (void)onUpgradeWithDbHelper:(EMSSQLiteHelper *)dbHelper
                   oldVersion:(int)oldVersion
                   newVersion:(int)newVersion {
    for (int i = oldVersion; i < newVersion; ++i) {
        for (NSString *sqlCommand in MIGRATION[(NSUInteger) i]) {
            [dbHelper executeCommand:sqlCommand];
        }
        [dbHelper executeCommand:SCHEMA_UPGRADE_SET_VERSION(i + 1)];
    }
}

- (int)schemaVersion {
    return 1;
}

@end