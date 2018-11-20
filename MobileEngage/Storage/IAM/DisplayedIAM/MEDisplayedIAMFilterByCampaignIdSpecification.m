//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "MEDisplayedIAMFilterByCampaignIdSpecification.h"
#import "MEDisplayedIAMContract.h"

@implementation MEDisplayedIAMFilterByCampaignIdSpecification

- (instancetype)initWithCampaignId:(NSString *)campaignId {
    self = [super init];
    if (self) {
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