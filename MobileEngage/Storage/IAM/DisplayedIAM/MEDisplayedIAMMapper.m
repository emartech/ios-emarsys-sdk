//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "MEDisplayedIAMMapper.h"
#import "MEDisplayedIAM.h"
#import "MEDisplayedIAMContract.h"

@implementation MEDisplayedIAMMapper

- (id)modelFromStatement:(sqlite3_stmt *)statement {
    NSString *campaignId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 1)];
    return [[MEDisplayedIAM alloc] initWithCampaignId:campaignId timestamp:timestamp];
}

- (sqlite3_stmt *)bindStatement:(sqlite3_stmt *)statement fromModel:(MEDisplayedIAM *)model {
    sqlite3_bind_text(statement, 1, [[model campaignId] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(statement, 2, [[model timestamp] timeIntervalSince1970]);
    return statement;
}

- (NSString *)tableName {
    return TABLE_NAME_DISPLAYED_IAM;
}


- (NSUInteger)fieldCount {
    return 2;
}


@end