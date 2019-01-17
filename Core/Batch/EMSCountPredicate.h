//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSPredicate.h"

@interface EMSCountPredicate : EMSPredicate<NSArray *>

- (instancetype)initWithThreshold:(int)threshold;

@end