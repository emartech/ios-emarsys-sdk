//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "MESchemaDelegate.h"
#import "MEDisplayedIAMContract.h"
#import "MEButtonClickContract.h"

@implementation MESchemaDelegate


- (void)onCreateWithDbHelper:(EMSSQLiteHelper *)dbHelper {
    [dbHelper executeCommand:SQL_CREATE_TABLE_DISPLAYED_IAM];
    [dbHelper executeCommand:SQL_CREATE_TABLE_BUTTON_CLICK];
}

- (void)onUpgradeWithDbHelper:(EMSSQLiteHelper *)dbHelper oldVersion:(int)oldversion newVersion:(int)newVersion {
}

- (int)schemaVersion {
    return 1;
}

@end