//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSRequestModelSelectFirstSpecification.h"
#import "EMSRequestContract.h"

@implementation EMSRequestModelSelectFirstSpecification

- (NSString *)sql {
    return SQL_SELECTFIRST;
}

- (void)bindStatement:(sqlite3_stmt *)statement {
}

@end