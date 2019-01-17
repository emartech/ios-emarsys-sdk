//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSCountPredicate.h"

@interface EMSCountPredicate ()

@property(nonatomic, assign) int threshold;

@end

@implementation EMSCountPredicate

- (instancetype)initWithThreshold:(int)threshold {
    NSParameterAssert(threshold > 0);
    if (self = [super init]) {
        _threshold = threshold;
    }
    return self;
}

- (BOOL)evaluate:(NSArray *)value {
    NSParameterAssert(value);
    return [value count] >= self.threshold;
}


@end