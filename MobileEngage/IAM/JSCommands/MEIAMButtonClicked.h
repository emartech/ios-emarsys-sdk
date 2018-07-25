//
//  Copyright © 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"
#import "MEButtonClickRepository.h"
#import "MEInAppTrackingProtocol.h"

@interface MEIAMButtonClicked : NSObject <MEIAMJSCommandProtocol>

@property(nonatomic, readonly) NSString *campaignId;
@property(nonatomic, readonly) MEButtonClickRepository *repository;
@property(nonatomic, readonly) id<MEInAppTrackingProtocol> inAppTracker;

- (instancetype)initWithCampaignId:(NSString *)campaignId
                        repository:(MEButtonClickRepository *)repository
                      inAppTracker:(id <MEInAppTrackingProtocol>)inAppTracker;

@end
