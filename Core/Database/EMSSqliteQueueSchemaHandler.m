//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSqliteQueueSchemaHandler.h"
#import "EMSSchemaContract.h"
#import "EMSLogger.h"
#import "EMSCoreTopic.h"

@implementation EMSSqliteQueueSchemaHandler

- (void)onCreateWithDbHelper:(EMSSQLiteHelper *)dbHelper {
    [EMSLogger logWithTopic:EMSCoreTopic.offlineTopic
                    message:@"Creating new database"];
    [self onUpgradeWithDbHelper:dbHelper
                     oldVersion:0
                     newVersion:[self schemaVersion]];
}

- (void)onUpgradeWithDbHelper:(EMSSQLiteHelper *)dbHelper
                   oldVersion:(int)oldVersion
                   newVersion:(int)newVersion {
    [EMSLogger logWithTopic:EMSCoreTopic.offlineTopic
                    message:[NSString stringWithFormat:@"Upgrading existing database from: %@ to: %@",
                                                       @(oldVersion),
                                                       @(newVersion)]];
    for (int i = oldVersion; i < newVersion; ++i) {
        for (NSString *sqlCommand in MIGRATION[(NSUInteger) i]) {
            [dbHelper executeCommand:sqlCommand];
        }
    }
}

- (int)schemaVersion {
    return 3;
}

@end