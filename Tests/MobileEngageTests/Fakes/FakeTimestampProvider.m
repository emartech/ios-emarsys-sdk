//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "FakeTimestampProvider.h"

@interface FakeTimestampProvider ()
@property(nonatomic, strong) NSArray<NSDate *> *timestamps;
@property(nonatomic, assign) NSUInteger timestampIndex;
@end

@implementation FakeTimestampProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentDate = [NSDate date];
    }
    return self;
}

- (instancetype)initWithTimestamps:(NSArray<NSDate *> *)timestamps {
    self = [super init];
    if (self) {
        _timestamps = timestamps;
    }
    return self;
}


- (NSDate *)provideTimestamp {
    NSDate *result;
    if (self.timestamps) {
        result = self.timestamps[self.timestampIndex];
        if (self.timestampIndex < self.timestamps.count - 1) {
            self.timestampIndex++;
        }
    } else {
        result = self.currentDate;
    }
    return result;
}

@end