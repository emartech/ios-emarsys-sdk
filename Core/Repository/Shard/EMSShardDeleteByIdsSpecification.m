//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSSchemaContract.h"
#import "EMSShard.h"
#import "EMSShardDeleteByIdsSpecification.h"

@interface EMSShardDeleteByIdsSpecification ()

@property(nonatomic, strong) NSMutableArray<NSString *> *shardIds;

@end

@implementation EMSShardDeleteByIdsSpecification

- (instancetype)initWithShards:(NSArray<EMSShard *> *)shards {
    if (self = [super init]) {
        _shardIds = [NSMutableArray array];
        for (EMSShard *shard in shards) {
            [_shardIds addObject:shard.shardId];
        }
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToSpecification:other];
}

- (BOOL)isEqualToSpecification:(EMSShardDeleteByIdsSpecification *)specification {
    if (self == specification)
        return YES;
    if (specification == nil)
        return NO;
    if (self.shardIds != specification.shardIds && ![self.shardIds isEqualToArray:specification.shardIds])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [self.shardIds hash];
}

- (NSString *)selection {
    return [NSString stringWithFormat:@"%@%@", SHARD_COLUMN_NAME_SHARD_ID,
                                      [self generateInStatementWithArgs:[self selectionArgs]]];
}

- (NSArray<NSString *> *)selectionArgs {
    return [NSArray arrayWithArray:self.shardIds];
}


@end