//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSqliteQueueSchemaHandler.h"
#import "EMSRequestContract.h"
#import "EMSLogger.h"
#import "EMSCoreTopic.h"

@implementation EMSSqliteQueueSchemaHandler

- (void)onCreateWithDbHelper:(EMSSQLiteHelper *)dbHelper {
    [EMSLogger logWithTopic:EMSCoreTopic.offlineTopic
                    message:@"Creating new database"];
    [dbHelper executeCommand:SQL_CREATE_TABLE];
}

- (void)onUpgradeWithDbHelper:(EMSSQLiteHelper *)dbHelper
                   oldVersion:(int)oldVersion
                   newVersion:(int)newVersion {
    [EMSLogger logWithTopic:EMSCoreTopic.offlineTopic
                    message:[NSString stringWithFormat:@"Upgrading existing database from: %@ to: %@", @(oldVersion), @(newVersion)]];
    switch (oldVersion) {
        case 1:
            [dbHelper executeCommand:SCHEMA_UPGRADE_FROM_1_TO_2];
            [dbHelper executeCommand:SET_DEFAULT_VALUES_FROM_1_TO_2 withTimeIntervalValue:DEFAULT_REQUESTMODEL_EXPIRY];
        default:
            break;
    }
}

- (int)schemaVersion {
    return 2;
}

@end