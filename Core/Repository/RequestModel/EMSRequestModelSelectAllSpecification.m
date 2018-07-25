//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSRequestModelSelectAllSpecification.h"
#import "EMSRequestContract.h"

@implementation EMSRequestModelSelectAllSpecification

- (NSString *)sql {
    return SQL_SELECTALL;
}

- (void)bindStatement:(sqlite3_stmt *)statement {
}

@end