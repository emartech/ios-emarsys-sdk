//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "MEIAMCleanupResponseHandlerV3.h"
#import "EMSFilterByValuesSpecification.h"
#import "EMSSchemaContract.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"

@interface MEIAMCleanupResponseHandlerV3 ()

@property(nonatomic, strong) MEButtonClickRepository *buttonClickRepository;
@property(nonatomic, strong) MEDisplayedIAMRepository *displayedIAMRepository;
@property(nonatomic, strong) EMSEndpoint *endpoint;

@end

@implementation MEIAMCleanupResponseHandlerV3

- (instancetype)initWithButtonClickRepository:(MEButtonClickRepository *)buttonClickRepository
                         displayIamRepository:(MEDisplayedIAMRepository *)displayedIAMRepository
                                     endpoint:(EMSEndpoint *)endpoint {
    NSParameterAssert(buttonClickRepository);
    NSParameterAssert(displayedIAMRepository);
    NSParameterAssert(endpoint);
    if (self = [super init]) {
        _buttonClickRepository = buttonClickRepository;
        _displayedIAMRepository = displayedIAMRepository;
        _endpoint = endpoint;
    }
    return self;
}

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response {
    if (![self.endpoint isMobileEngageUrl:[response.requestModel.url absoluteString]]
            || [MEExperimental isFeatureEnabled:EMSInnerFeature.eventServiceV4]) {
        return NO;
    }

    id messages = response.parsedBody[@"oldCampaigns"];
    return [messages isKindOfClass:[NSArray class]] && [messages count] > 0;
}

- (void)handleResponse:(EMSResponseModel *)response {
    for (id campaign in response.parsedBody[@"oldCampaigns"]) {
        NSString *campaignId = [NSString stringWithFormat:@"%@", campaign];
        EMSFilterByValuesSpecification *filterByCampaignIdSpecification = [[EMSFilterByValuesSpecification alloc] initWithValues:@[campaignId]
                                                                                                                          column:COLUMN_NAME_CAMPAIGN_ID];
        [self.buttonClickRepository remove:filterByCampaignIdSpecification];
        [self.displayedIAMRepository remove:filterByCampaignIdSpecification];
    }
}

@end
