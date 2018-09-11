//
// Created by mhunyady on 2018. 09. 11..
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSTimestampProvider;
@class EMSUUIDProvider;
#define DEFAULT_SHARD_TTL FLT_MAX

@interface EMSShardBuilder : NSObject

@property(nonatomic, readonly) NSString *shardId;
@property(nonatomic, readonly) NSString *type;
@property(nonatomic, readonly) NSMutableDictionary<NSString *, id> *data;
@property(nonatomic, readonly) NSDate *timestamp;
@property(nonatomic, readonly) NSTimeInterval ttl;

- (instancetype)initWithTimestampProvider:(EMSTimestampProvider *)timestampProvider
                             uuidProvider:(EMSUUIDProvider *)uuidProvider;

- (EMSShardBuilder *)setType:(NSString *)type;

- (EMSShardBuilder *)setTTL:(NSTimeInterval)ttl;

- (EMSShardBuilder *)payloadEntryWithKey:(NSString *)key
                                   value:(id)value;
@end