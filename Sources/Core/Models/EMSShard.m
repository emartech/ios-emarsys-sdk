//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSShard.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"

@implementation EMSShard

- (instancetype)initWithShardId:(NSString *)shardId
                           type:(NSString *)type
                           data:(NSDictionary<NSString *, id> *)data
                      timestamp:(NSDate *)timestamp
                            ttl:(NSTimeInterval)ttl {
    if (self = [super init]) {
        NSParameterAssert(shardId);
        NSParameterAssert(type);
        NSParameterAssert(timestamp);
        NSParameterAssert(data);
        _shardId = shardId;
        _type = type;
        _timestamp = timestamp;
        _ttl = ttl;
        _data = data;
    }
    return self;
}

+ (instancetype)makeWithBuilder:(EMSShardBuilderBlock)builderBlock
              timestampProvider:(EMSTimestampProvider *)timestampProvider
                   uuidProvider:(EMSUUIDProvider *)uuidProvider {
    NSParameterAssert(timestampProvider);
    NSParameterAssert(uuidProvider);
    NSParameterAssert(builderBlock);
    EMSShardBuilder *builder = [[EMSShardBuilder alloc] initWithTimestampProvider:timestampProvider
                                                                     uuidProvider:uuidProvider];
    builderBlock(builder);
    return [[self alloc] initWithBuilder:builder];
}

- (instancetype)initWithBuilder:(EMSShardBuilder *)builder {
    if (self = [super init]) {
        _timestamp = builder.timestamp;
        _ttl = builder.ttl;
        _type = builder.type;
        _data = builder.data;
        _shardId = builder.shardId;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.shardId=%@", self.shardId];
    [description appendFormat:@", self.type=%@", self.type];
    [description appendFormat:@", self.data=%@", self.data];
    [description appendFormat:@", self.timestamp=%@", self.timestamp];
    [description appendFormat:@", self.ttl=%lf", self.ttl];
    [description appendString:@">"];
    return description;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToShard:other];
}

- (BOOL)isEqualToShard:(EMSShard *)shard {
    if (self == shard)
        return YES;
    if (shard == nil)
        return NO;
    if (self.shardId != shard.shardId && ![self.shardId isEqualToString:shard.shardId])
        return NO;
    if (self.type != shard.type && ![self.type isEqualToString:shard.type])
        return NO;
    if (self.data != shard.data && ![self.data isEqualToDictionary:shard.data])
        return NO;
    if (self.timestamp != shard.timestamp && [self.timestamp timeIntervalSince1970] != [shard.timestamp timeIntervalSince1970])
        return NO;
    if (self.ttl != shard.ttl)
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.shardId hash];
    hash = hash * 31u + [self.type hash];
    hash = hash * 31u + [self.data hash];
    hash = hash * 31u + [self.timestamp hash];
    hash = hash * 31u + [[NSNumber numberWithDouble:self.ttl] hash];
    return hash;
}

@end