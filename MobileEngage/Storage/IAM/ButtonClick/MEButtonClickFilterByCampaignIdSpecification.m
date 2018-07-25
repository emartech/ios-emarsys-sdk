//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import <sqlite3.h>
#import "MEButtonClickFilterByCampaignIdSpecification.h"
#import "MEButtonClickContract.h"

@implementation MEButtonClickFilterByCampaignIdSpecification

- (instancetype)initWithCampaignId:(NSString *)campaignId {
    if (self = [super init]) {
        _campaignId = campaignId;
    }
    return self;
}

- (NSString *)sql {
    return [NSString stringWithFormat:@"WHERE %@ = ?", COLUMN_NAME_CAMPAIGN_ID];
}

- (void)bindStatement:(sqlite3_stmt *)statement {
    sqlite3_bind_text(statement, 1, [self.campaignId UTF8String], -1, SQLITE_TRANSIENT);
}

@end
