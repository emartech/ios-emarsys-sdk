//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import "MEButtonClickFilterByCampaignIdSpecification.h"
#import "MEButtonClickContract.h"

@implementation MEButtonClickFilterByCampaignIdSpecification

- (instancetype)initWithCampaignId:(NSString *)campaignId {
    if (self = [super init]) {
        _campaignId = campaignId;
    }
    return self;
}

- (NSString *)selection {
    return [NSString stringWithFormat:@"%@ = ?", COLUMN_NAME_CAMPAIGN_ID];
}

- (NSArray<NSString *> *)selectionArgs {
    return @[self.campaignId];
}


@end
