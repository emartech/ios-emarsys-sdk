//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "MEDisplayedIAMMapper.h"
#import "MEDisplayedIAM.h"
#import "MEDisplayedIAMContract.h"
#import "EMSMacros.h"
#import "EMSStatusLog.h"

@interface MEDisplayedIAMMapper()

- (nullable NSString *)mapToString:(const unsigned char *)utf8String;

@end

@implementation MEDisplayedIAMMapper

- (id)modelFromStatement:(sqlite3_stmt *)statement {
    NSString *campaignId = [self mapToString:sqlite3_column_text(statement, 0)];
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 1)];
    if (!campaignId || !timestamp) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"campaignId"] = campaignId;
        parameters[@"timestamp"] = [timestamp description];
        EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                                 sel:_cmd
                                                          parameters:[NSDictionary dictionaryWithDictionary:parameters]
                                                              status:nil];
        EMSLog(logEntry, LogLevelError);
    }
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

- (nullable NSString *)mapToString:(const unsigned char *)utf8String {
    NSString *result = nil;
    if (utf8String) {
        result = [NSString stringWithUTF8String:(char *)utf8String];
    }
    return result;
}

@end
