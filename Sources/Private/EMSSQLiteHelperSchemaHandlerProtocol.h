//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSSQLiteHelperProtocol.h"

@protocol EMSSQLiteHelperSchemaHandlerProtocol <NSObject>

- (void)onCreateWithDbHelper:(id <EMSSQLiteHelperProtocol>)dbHelper;

- (void)onUpgradeWithDbHelper:(id <EMSSQLiteHelperProtocol>)dbHelper
                   oldVersion:(int)oldVersion
                   newVersion:(int)newVersion;

- (int)schemaVersion;

@end