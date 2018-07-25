//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSSQLSpecificationProtocol.h"

@interface MEDisplayedIAMFilterByCampaignIdSpecification : NSObject <EMSSQLSpecificationProtocol>

@property (nonatomic, readonly) NSString *campaignId;

- (instancetype)initWithCampaignId:(NSString *)campaignId;


@end