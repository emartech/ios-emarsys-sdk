//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSShardBuilder.h"
#import "EMSUUIDProvider.h"
#import "EMSTimestampProvider.h"

@implementation EMSShardBuilder

- (instancetype)initWithTimestampProvider:(EMSTimestampProvider *)timestampProvider
                             uuidProvider:(EMSUUIDProvider *)uuidProvider {
    if (self = [super init]) {
        _shardId = [uuidProvider provideUUIDString];
        _timestamp = [timestampProvider provideTimestamp];
        _ttl = DEFAULT_SHARD_TTL;
        _data = [NSMutableDictionary<NSString *, id> new];
    }
    return self;
}

- (EMSShardBuilder *)setType:(NSString *)type {
    _type = type;
    return self;
}

- (EMSShardBuilder *)setTTL:(NSTimeInterval)ttl {
    _ttl = ttl;
    return self;
}

- (EMSShardBuilder *)addPayloadEntryWithKey:(NSString *)key value:(id)value {
    _data[key] = value;
    return self;
}

- (EMSShardBuilder *)addPayloadEntries:(NSDictionary<NSString *, id> *)entries {
    [_data addEntriesFromDictionary:entries];
    return self;
}


@end