//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSCountMapper.h"


@implementation EMSCountMapper

- (id)modelFromStatement:(sqlite3_stmt *)statement {
    return @(sqlite3_column_int(statement, 0));
}

- (sqlite3_stmt *)bindStatement:(sqlite3_stmt *)statement fromModel:(id)model {
    NSAssert(NO, @"NOT IMPLEMENTED");
    return NULL;
}

- (NSString *)tableName {
    return nil;
}


- (NSUInteger)fieldCount {
    return 1;
}

@end