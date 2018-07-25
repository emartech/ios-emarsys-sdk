//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSRequestModelCountSpecification.h"
#import "EMSRequestContract.h"


@implementation EMSRequestModelCountSpecification

- (NSString *)sql {
    return SQL_SELECTFIRST;
}

- (void)bindStatement:(sqlite3_stmt *)statement {

}


@end