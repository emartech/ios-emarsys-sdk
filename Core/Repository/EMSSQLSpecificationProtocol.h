//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@protocol EMSSQLSpecificationProtocol

- (NSString *)sql;

- (void)bindStatement:(sqlite3_stmt *)statement;


- (NSString *)selection;

- (NSArray<NSString *> *)selectionArgs;

- (NSString *)orderBy;

- (NSString *)limit;

@end