//
//  Copyright © 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSSQLSpecificationProtocol.h"
#import "EMSCommonSQLSpecification.h"

@interface MEButtonClickFilterByCampaignIdSpecification : EMSCommonSQLSpecification

@property (nonatomic, readonly) NSString *campaignId;

- (instancetype)initWithCampaignId:(NSString *)campaignId;

@end
