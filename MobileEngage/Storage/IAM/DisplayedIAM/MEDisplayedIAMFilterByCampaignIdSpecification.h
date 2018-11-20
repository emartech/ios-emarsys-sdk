//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSSQLSpecificationProtocol.h"
#import "EMSCommonSQLSpecification.h"

@interface MEDisplayedIAMFilterByCampaignIdSpecification : EMSCommonSQLSpecification

@property (nonatomic, readonly) NSString *campaignId;

- (instancetype)initWithCampaignId:(NSString *)campaignId;


@end