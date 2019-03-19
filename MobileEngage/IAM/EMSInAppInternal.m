//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSInAppInternal.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"

@interface EMSInAppInternal ()

@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSRequestFactory *requestFactory;

@end

@implementation EMSInAppInternal

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory {
    NSParameterAssert(requestManager);
    NSParameterAssert(requestFactory);
    if (self = [super init]) {
        _requestManager = requestManager;
        _requestFactory = requestFactory;
    }
    return self;
}

- (void)trackInAppDisplay:(NSString *)campaignId {
    if (campaignId) {
        EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"inapp:viewed"
                                                                                  eventAttributes:@{@"message_id": campaignId}
                                                                                        eventType:EventTypeInternal];
        [self.requestManager submitRequestModel:requestModel
                            withCompletionBlock:nil];
    }
}

- (void)trackInAppClick:(NSString *)campaignId
               buttonId:(NSString *)buttonId {
    if (campaignId && buttonId) {
        EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"inapp:click"
                                                                                  eventAttributes:@{
                                                                                          @"message_id": campaignId,
                                                                                          @"button_id": buttonId
                                                                                  }
                                                                                        eventType:EventTypeInternal];
        [self.requestManager submitRequestModel:requestModel
                            withCompletionBlock:nil];
    }
}

@end