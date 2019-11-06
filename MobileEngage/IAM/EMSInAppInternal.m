//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSInAppInternal.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "MEInAppMessage.h"

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

- (void)trackInAppDisplay:(MEInAppMessage *)inAppMessage {
    if (inAppMessage.campaignId) {
        NSMutableDictionary *mutableEventAttributes = [NSMutableDictionary dictionary];
        mutableEventAttributes[@"campaignId"] = inAppMessage.campaignId;
        mutableEventAttributes[@"sid"] = inAppMessage.sid;
        mutableEventAttributes[@"url"] = inAppMessage.url;
        EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"inapp:viewed"
                                                                                  eventAttributes:[NSDictionary dictionaryWithDictionary:mutableEventAttributes]
                                                                                        eventType:EventTypeInternal];
        [self.requestManager submitRequestModel:requestModel
                            withCompletionBlock:nil];
    }
}

- (void)trackInAppClick:(MEInAppMessage *)inAppMessage
               buttonId:(NSString *)buttonId {
    if (inAppMessage.campaignId && buttonId) {
        NSMutableDictionary *mutableEventAttributes = [NSMutableDictionary dictionary];
        mutableEventAttributes[@"campaignId"] = inAppMessage.campaignId;
        mutableEventAttributes[@"buttonId"] = buttonId;
        mutableEventAttributes[@"sid"] = inAppMessage.sid;
        mutableEventAttributes[@"url"] = inAppMessage.url;

        EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"inapp:click"
                                                                                  eventAttributes:[NSDictionary dictionaryWithDictionary:mutableEventAttributes]
                                                                                        eventType:EventTypeInternal];
        [self.requestManager submitRequestModel:requestModel
                            withCompletionBlock:nil];
    }
}

@end