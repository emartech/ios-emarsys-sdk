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

@end