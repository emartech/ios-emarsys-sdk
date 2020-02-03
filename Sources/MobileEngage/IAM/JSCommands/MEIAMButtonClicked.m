//
//  Copyright © 2018 Emarsys. All rights reserved.
//


#import "MEIAMButtonClicked.h"
#import "MEIAMCommandResultUtils.h"
#import "EMSDictionaryValidator.h"
#import "NSDictionary+EMSCore.h"
#import "MEInAppMessage.h"

@implementation MEIAMButtonClicked

- (instancetype)initWithInAppMessage:(MEInAppMessage *)inAppMessage
                          repository:(MEButtonClickRepository *)repository
                        inAppTracker:(id <MEInAppTrackingProtocol>)inAppTracker {
    if (self = [super init]) {
        _inAppMessage = inAppMessage;
        _repository = repository;
        _inAppTracker = inAppTracker;
    }
    return self;
}

+ (NSString *)commandName {
    return @"buttonClicked";
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {
    NSString *eventId = message[@"id"];
    NSArray<NSString *> *errors = [message validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"buttonId" withType:[NSString class]];
    }];

    if ([errors count] > 0) {
        resultBlock([MEIAMCommandResultUtils createErrorResultWith:eventId errorArray:errors]);
    }

    NSString *buttonId = [message stringValueForKey:@"buttonId"];
    if (buttonId) {
        [self.repository add:[[MEButtonClick alloc] initWithCampaignId:self.inAppMessage.campaignId
                                                              buttonId:buttonId
                                                             timestamp:[NSDate date]]];
        [self.inAppTracker trackInAppClick:self.inAppMessage
                                  buttonId:buttonId];
        resultBlock([MEIAMCommandResultUtils createSuccessResultWith:eventId]);
    } else {
        resultBlock([MEIAMCommandResultUtils createMissingParameterErrorResultWith:eventId
                                                                  missingParameter:@"buttonId"]);
    }
}

@end
