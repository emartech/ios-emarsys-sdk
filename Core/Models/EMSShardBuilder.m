//
// Created by mhunyady on 2018. 09. 11..
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

- (EMSShardBuilder *)payloadEntryWithKey:(NSString *)key value:(id)value {
    _data[key] = value;
    return self;
}

@end