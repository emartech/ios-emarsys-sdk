//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MERequestModelSelectEventsSpecification.h"
#import "EMSSchemaContract.h"

@implementation MERequestModelSelectEventsSpecification


- (NSString *)sql {
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ LIKE '%%/v3/devices/_%%/events';", REQUEST_TABLE_NAME, REQUEST_COLUMN_NAME_URL];
}

- (void)bindStatement:(sqlite3_stmt *)statement {
}

@end