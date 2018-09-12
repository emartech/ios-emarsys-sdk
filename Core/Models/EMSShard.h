//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSShardBuilder.h"

@class EMSTimestampProvider;
@class EMSUUIDProvider;


@interface EMSShard : NSObject

@property(nonatomic, readonly) NSString *shardId;
@property(nonatomic, readonly) NSString *type;
@property(nonatomic, readonly) NSDictionary<NSString *, id> *data;
@property(nonatomic, readonly) NSDate *timestamp;
@property(nonatomic, readonly) NSTimeInterval ttl;

typedef void(^EMSShardBuilderBlock)(EMSShardBuilder *builder);

- (instancetype)initWithShardId:(NSString *)shardId
                           type:(NSString *)type
                           data:(NSDictionary<NSString *, id> *)data
                      timestamp:(NSDate *)timestamp
                            ttl:(NSTimeInterval)ttl;

+ (instancetype)makeWithBuilder:(EMSShardBuilderBlock)builderBlock
              timestampProvider:(EMSTimestampProvider *)timestampProvider
                   uuidProvider:(EMSUUIDProvider *)uuidProvider;
@end