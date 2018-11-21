//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSQueryOldestRowSpecification.h"

@implementation EMSQueryOldestRowSpecification

- (NSString *)orderBy {
    return @"ROWID ASC";
}

- (NSString *)limit {
    return @"1";
}

@end
