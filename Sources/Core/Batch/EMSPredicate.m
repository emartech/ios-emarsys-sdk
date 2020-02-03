//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSPredicate.h"

@implementation EMSPredicate

- (BOOL)evaluate:(id)value {
    NSAssert(NO, @"Abstract method must be implemented!");
    return NO;
}

@end