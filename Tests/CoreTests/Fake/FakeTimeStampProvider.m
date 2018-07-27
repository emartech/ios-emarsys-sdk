//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "FakeTimeStampProvider.h"

@implementation FakeTimeStampProvider {
    NSUInteger _timestampIndex;
}

- (instancetype)initWithTimestamps:(NSArray<NSDate *> *)timestamps {
    self = [super init];
    if (self) {
        self.timestamps = timestamps;
    }

    return self;
}

+ (instancetype)providerWithTimestamps:(NSArray<NSDate *> *)timestamps {
    return [[self alloc] initWithTimestamps:timestamps];
}

- (NSDate *)provideTimestamp {
    NSDate *result;
    if (self.timestamps) {
        result = self.timestamps[_timestampIndex];
        if (_timestampIndex < self.timestamps.count - 1) {
            _timestampIndex++;
        }
    }
    return result;
}

@end