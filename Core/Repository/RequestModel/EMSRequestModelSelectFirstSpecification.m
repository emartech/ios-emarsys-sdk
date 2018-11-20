//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSRequestModelSelectFirstSpecification.h"

@implementation EMSRequestModelSelectFirstSpecification

- (NSString *)orderBy {
    return @"ROWID ASC";
}

- (NSString *)limit {
    return @"1";
}

@end