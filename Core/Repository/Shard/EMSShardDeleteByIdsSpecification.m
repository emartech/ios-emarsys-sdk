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

@end