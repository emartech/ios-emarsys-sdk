//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import "MEButtonClickMapper.h"
#import "MEButtonClick.h"
#import "MEButtonClickContract.h"

@implementation MEButtonClickMapper

- (id)modelFromStatement:(sqlite3_stmt *)statement {
    NSString *campaignId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
    NSString *buttonId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 2)];
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

@end
