//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSTimestampProvider.h"

@interface FakeTimeStampProvider : EMSTimestampProvider

@property(nonatomic, strong) NSArray<NSDate *> *timestamps;

- (instancetype)initWithTimestamps:(NSArray<NSDate *> *)timestamps;

+ (instancetype)providerWithTimestamps:(NSArray<NSDate *> *)timestamps;


@end