//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EMSShard : NSObject

@property(nonatomic, readonly) NSString *shardId;
@property(nonatomic, readonly) NSString *type;
@property(nonatomic, readonly) NSDictionary<NSString *, id> *data;
@property(nonatomic, readonly) NSDate *timestamp;
@property(nonatomic, readonly) NSTimeInterval ttl;

- (instancetype)initWithShardId:(NSString *)shardId
                           type:(NSString *)type
                           data:(NSDictionary<NSString *, id> *)data
                      timestamp:(NSDate *)timestamp
                            ttl:(NSTimeInterval)ttl;
@end