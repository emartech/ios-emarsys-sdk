//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSShardQueryAllSpecification.h"
#import "EMSSchemaContract.h"

@implementation EMSShardQueryAllSpecification

- (NSString *)sql {
    return SQL_SHARD_SELECTALL;
}

- (void)bindStatement:(sqlite3_stmt *)statement {

}

@end