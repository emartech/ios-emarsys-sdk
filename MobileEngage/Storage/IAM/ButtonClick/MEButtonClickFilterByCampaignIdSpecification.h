//
//  Copyright © 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSSQLSpecificationProtocol.h"

@interface MEButtonClickFilterByCampaignIdSpecification : NSObject <EMSSQLSpecificationProtocol>

@property (nonatomic, readonly) NSString *campaignId;

- (instancetype)initWithCampaignId:(NSString *)campaignId;

@end
