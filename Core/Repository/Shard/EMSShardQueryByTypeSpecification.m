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
