//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import "EMSOnEventResponseHandler.h"
#import "EMSActionProtocol.h"
#import "MEDisplayedIAM.h"

@interface EMSOnEventResponseHandler ()

@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) id <EMSRepositoryProtocol> repository;
@property(nonatomic, strong) EMSActionFactory *actionFactory;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;

@end

@implementation EMSOnEventResponseHandler

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                displayedIAMRepository:(id <EMSRepositoryProtocol>)repository
                         actionFactory:(EMSActionFactory *)actionFactory
                     timestampProvider:(EMSTimestampProvider *)timestampProvider {
    if (self = [super init]) {
        _requestManager = requestManager;
        _requestFactory = requestFactory;
        _repository = repository;
        _actionFactory = actionFactory;
        _timestampProvider = timestampProvider;
    }
    return self;
}

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response {
    return response.parsedBody[@"onEventAction"][@"actions"];
}

- (void)handleResponse:(EMSResponseModel *)response {
    NSArray *actions = response.parsedBody[@"onEventAction"][@"actions"];
    for (NSDictionary *actionDict in actions) {
        [[self.actionFactory createActionWithActionDictionary:actionDict] execute];
    }
    NSString *campaignId = response.parsedBody[@"campaignId"];
    if (campaignId) {
        [self.repository add:[[MEDisplayedIAM alloc] initWithCampaignId:campaignId
                                                              timestamp:[self.timestampProvider provideTimestamp]]];

        NSDictionary *eventAttributes = @{@"campaignId": campaignId};
        EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"inapp:viewed"
                                                                                  eventAttributes:eventAttributes
                                                                                        eventType:EventTypeInternal];
        [self.requestManager submitRequestModel:requestModel
                            withCompletionBlock:nil];
    }
}

@end
