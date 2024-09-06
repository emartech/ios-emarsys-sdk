//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import "MEButtonClickMapper.h"
#import "MEButtonClick.h"
#import "MEButtonClickContract.h"
#import "EMSMacros.h"
#import "EMSStatusLog.h"

@interface MEButtonClickMapper()

- (nullable NSString *)mapToString:(const unsigned char *)utf8String;

@end

@implementation MEButtonClickMapper

- (id)modelFromStatement:(sqlite3_stmt *)statement {
    NSString *campaignId = [self mapToString:sqlite3_column_text(statement, 0)];
    NSString *buttonId = [self mapToString:sqlite3_column_text(statement, 1)];
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 2)];
    if (!campaignId || !buttonId || !timestamp) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"campaignId"] = campaignId;
        parameters[@"buttonId"] = buttonId;
        parameters[@"timestamp"] = [timestamp description];
        EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                                 sel:_cmd
                                                          parameters:[NSDictionary dictionaryWithDictionary:parameters]
                                                              status:nil];
        EMSLog(logEntry, LogLevelError);
    }
    return [[MEButtonClick alloc] initWithCampaignId:campaignId
                                            buttonId:buttonId
                                           timestamp:timestamp];
}

- (sqlite3_stmt *)bindStatement:(sqlite3_stmt *)statement fromModel:(MEButtonClick *)model {
    sqlite3_bind_text(statement, 1, [[model campaignId] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, [[model buttonId] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(statement, 3, [[model timestamp] timeIntervalSince1970]);
    return statement;
}

- (NSString *)tableName {
    return TABLE_NAME_BUTTON_CLICK;
}


- (NSUInteger)fieldCount {
    return 3;
}

- (nullable NSString *)mapToString:(const unsigned char *)utf8String {
    NSString *result = nil;
    if (utf8String) {
        result = [NSString stringWithUTF8String:(char *)utf8String];
    }
    return result;
}

@end
