//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import "MEIAMCleanupResponseHandlerV4.h"
#import "EMSFilterByValuesSpecification.h"
#import "EMSSchemaContract.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"
#import "EMSResponseModel+EMSCore.h"

@interface MEIAMCleanupResponseHandlerV4 ()

@property(nonatomic, strong) MEButtonClickRepository *buttonClickRepository;
@property(nonatomic, strong) MEDisplayedIAMRepository *displayedIAMRepository;
@property(nonatomic, strong) EMSEndpoint *endpoint;

@end

@implementation MEIAMCleanupResponseHandlerV4

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
    if ([self.endpoint isMobileEngageUrl:response.requestModel.url.absoluteString] &&
            [MEExperimental isFeatureEnabled:EMSInnerFeature.eventServiceV4] &&
            [response isSuccess] &&
            ([self hasValues:@"viewedMessages"
               requestModel:response.requestModel] ||
            [self hasValues:@"clicks"
               requestModel:response.requestModel])) {
        return YES;
    }
    return NO;
}

- (void)handleResponse:(EMSResponseModel *)response {
    NSArray *clicks = response.requestModel.payload[@"clicks"];
    [self removeByCampaignObjects:clicks
                       repository:self.buttonClickRepository];

    NSArray *viewedMessages = response.requestModel.payload[@"viewedMessages"];
    [self removeByCampaignObjects:viewedMessages
                   repository:self.displayedIAMRepository];
}

- (void)removeByCampaignObjects:(NSArray *)campaignObjects
                 repository:(id <EMSRepositoryProtocol>)repository {
    NSMutableArray *campaignIdsToRemove = [NSMutableArray array];
    for (NSDictionary *campaignObject in campaignObjects) {
        NSString *campaignId = campaignObject[@"campaignId"];
        if (campaignId) {
            [campaignIdsToRemove addObject:campaignId];
        }
    }
    EMSFilterByValuesSpecification *filterByViewedCampaignIdSpecification = [[EMSFilterByValuesSpecification alloc] initWithValues:[NSArray arrayWithArray:campaignIdsToRemove]
                                                                                                                            column:COLUMN_NAME_CAMPAIGN_ID];
    [repository remove:filterByViewedCampaignIdSpecification];
}

- (BOOL)hasValues:(NSString *)value
     requestModel:(EMSRequestModel *)requestModel {
    return requestModel.payload[value] &&
            [requestModel.payload[value] isKindOfClass:[NSArray class]] &&
            [(NSArray *) requestModel.payload[value] count] > 0;
}

@end
