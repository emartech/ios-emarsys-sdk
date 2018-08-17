//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSShardMapper.h"
#import "NSDictionary+EMSCore.h"
#import "EMSShard.h"
#import "EMSSchemaContract.h"

@interface EMSShardMapper ()

- (NSData *)dataFromStatement:(sqlite3_stmt *)statement
                        index:(int)index;

- (BOOL)isNotNull:(sqlite3_stmt *)statement
          atIndex:(int)index;

@end

@implementation EMSShardMapper


- (id)modelFromStatement:(sqlite3_stmt *)statement {
    NSString *shardId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
    NSString *type = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
    NSDictionary<NSString *, NSString *> *data;
    if ([self isNotNull:statement atIndex:2]) {
        data = [NSDictionary dictionaryWithData:[self dataFromStatement:statement
                                                                  index:2]];
    }
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 3)];
    NSTimeInterval ttl = sqlite3_column_double(statement, 4);
    return [[EMSShard alloc] initWithShardId:shardId
                                        type:type
                                        data:data
                                   timestamp:timestamp
                                         ttl:ttl];
}

- (sqlite3_stmt *)bindStatement:(sqlite3_stmt *)statement
                      fromModel:(EMSShard *)model {
    sqlite3_bind_text(statement, 1, [[model shardId] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, [[model type] UTF8String], -1, SQLITE_TRANSIENT);
    NSData *data = [[model data] archive];
    sqlite3_bind_blob(statement, 3, [data bytes], (int) [data length], SQLITE_TRANSIENT);
    sqlite3_bind_double(statement, 4, [[model timestamp] timeIntervalSince1970]);
    sqlite3_bind_double(statement, 5, [model ttl]);
    return statement;
}

#pragma mark - Private methods

- (NSData *)dataFromStatement:(sqlite3_stmt *)statement
                        index:(int)index {
    const void *blob = sqlite3_column_blob(statement, index);
    NSUInteger size = (NSUInteger) sqlite3_column_bytes(statement, index);
    return [[NSData alloc] initWithBytes:blob
                                  length:size];
}

- (BOOL)isNotNull:(sqlite3_stmt *)statement
          atIndex:(int)index {
    return sqlite3_column_type(statement, index) != SQLITE_NULL;
}

- (NSString *)tableName {
    return SHARD_TABLE_NAME;
}


- (NSUInteger)fieldCount {
    return 5;
}


@end
