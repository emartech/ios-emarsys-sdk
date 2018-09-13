//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSShardDeleteByIdsSpecification.h"
#import "EMSSchemaContract.h"
#import "EMSShard.h"

@interface EMSShardDeleteByIdsSpecification()

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


- (NSString *)sql {
    NSString *ids = [NSString stringWithFormat:@"'%@'", [self.shardIds componentsJoinedByString:@"', '"]];
    return SQL_SHARD_DELETE_MULTIPLE_ITEM(ids);
}

- (void)bindStatement:(sqlite3_stmt *)statement {
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


@end