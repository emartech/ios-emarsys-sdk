//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSRequestModelSelectFirstSpecification.h"
#import "EMSSchemaContract.h"

@implementation EMSRequestModelSelectFirstSpecification

- (NSString *)sql {
    return SQL_REQUEST_SELECTFIRST;
}

- (NSString *)orderBy {
    return @"ROWID ASC";
}

- (NSString *)limit {
    return @"1";
}

@end