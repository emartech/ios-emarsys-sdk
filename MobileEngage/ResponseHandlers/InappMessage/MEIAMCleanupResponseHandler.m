//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "MEIAMCleanupResponseHandler.h"
#import "MEButtonClickFilterByCampaignIdSpecification.h"
#import "MEDisplayedIAMFilterByCampaignIdSpecification.h"
#import "MERequestMatcher.h"

@interface MEIAMCleanupResponseHandler()

@property (nonatomic, strong) MEButtonClickRepository *buttonClickRepository;
@property (nonatomic, strong) MEDisplayedIAMRepository *displayedIAMRepository;

@end


@implementation MEIAMCleanupResponseHandler

- (instancetype)initWithButtonClickRepository:(MEButtonClickRepository *)buttonClickRepository
                         displayIamRepository:(MEDisplayedIAMRepository *)displayedIAMRepository {
    if (self = [super init]) {
        _buttonClickRepository = buttonClickRepository;
        _displayedIAMRepository = displayedIAMRepository;
    }
    return self;
}

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response {
    if (![MERequestMatcher isV3CustomEventUrl:[response.requestModel.url absoluteString]]) {
        return NO;
    }

    id messages = response.parsedBody[@"old_messages"];
    return [messages isKindOfClass:[NSArray class]] && [messages count] > 0;
}

- (void)handleResponse:(EMSResponseModel *)response {
    for (NSString *campaignId in response.parsedBody[@"old_messages"]) {
        [self.buttonClickRepository remove:[[MEButtonClickFilterByCampaignIdSpecification alloc] initWithCampaignId:campaignId]];
        [self.displayedIAMRepository remove:[[MEDisplayedIAMFilterByCampaignIdSpecification alloc] initWithCampaignId:campaignId]];
    }
}

@end