//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSShardQueryByTypeSpecification.h"
#import "EMSSchemaContract.h"

@interface EMSShardQueryByTypeSpecification()

@property(nonatomic, strong) NSString *type;

@end

@implementation EMSShardQueryByTypeSpecification

- (instancetype)initWithType:(NSString *)type {
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

- (NSString *)sql {
    return SQL_SHARD_SELECT_BY_TYPE(self.type);
}

- (void)bindStatement:(sqlite3_stmt *)statement {
}

- (NSString *)selection {
    return [NSString stringWithFormat:@"%@ LIKE ?", SHARD_COLUMN_NAME_TYPE];
}

- (NSArray<NSString *> *)selectionArgs {
    return @[self.type];
}

- (NSString *)orderBy {
    return @"ROWID ASC";
}


@end
