//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSShard.h"


@implementation EMSShard

- (instancetype)initWithCategory:(NSString *)category
                       timestamp:(NSDate *)timestamp
                             ttl:(NSTimeInterval)ttl
                            data:(NSDictionary<NSString *, id> *)data {
    self = [super init];
    if (self) {
        NSParameterAssert(category);
        NSParameterAssert(timestamp);
        NSParameterAssert(data);
        _category = category;
        _timestamp = timestamp;
        _ttl = ttl;
        _data = data;
    }

    return self;
}

@end