//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "MEInApp.h"
#import "EMSInAppInternal.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "EMSDictionaryValidator.h"
#import "EMSTimestampProvider.h"
#import "NSDictionary+MobileEngage.h"
#import "EMSStatusLog.h"
#import "EMSMacros.h"

@interface EMSInAppInternal ()

@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) MEInApp *meInApp;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;

@end

@implementation EMSInAppInternal

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                               meInApp:(MEInApp *)meInApp
                     timestampProvider:(EMSTimestampProvider *)timestampProvider
                          uuidProvider:(EMSUUIDProvider *)uuidProvider {
    NSParameterAssert(requestManager);
    NSParameterAssert(requestFactory);
    NSParameterAssert(meInApp);
    NSParameterAssert(timestampProvider);
    NSParameterAssert(uuidProvider);
    if (self = [super init]) {
        _requestManager = requestManager;
        _requestFactory = requestFactory;
        _meInApp = meInApp;
        _timestampProvider = timestampProvider;
        _uuidProvider = uuidProvider;
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

- (void)handleInApp:(NSDictionary *)userInfo
              inApp:(NSDictionary *)inApp {
    NSDate *responseTimestamp = [self.timestampProvider provideTimestamp];
    NSArray *errors = [inApp validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"inAppData"
                           withType:[NSData class]];
        [validate valueExistsForKey:@"campaign_id"
                           withType:[NSString class]];
    }];
    if ([errors count] == 0) {
        NSString *html = [[NSString alloc] initWithData:inApp[@"inAppData"]
                                               encoding:NSUTF8StringEncoding];
        [self.meInApp showMessage:[[MEInAppMessage alloc] initWithCampaignId:inApp[@"campaign_id"]
                                                                       sid:[userInfo messageId]
                                                                       url:inApp[@"url"]
                                                                      html:html
                                                         responseTimestamp:responseTimestamp]
              completionHandler:nil];
    } else {
        [self handleNotPreloadedInapp:responseTimestamp
                             userInfo:userInfo
                                inApp:inApp];
    }
}

- (void)handleNotPreloadedInapp:(NSDate *)responseTimestamp
                       userInfo:(NSDictionary *)userInfo
                          inApp:(NSDictionary *)inApp {
    NSString *url = inApp[@"url"];
    if (url) {
        EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:url];
                    [builder setMethod:HTTPMethodGET];
                }
                                                       timestampProvider:self.timestampProvider
                                                            uuidProvider:self.uuidProvider];
        __weak typeof(self) weakSelf = self;
        [self.requestManager submitRequestModelNow:requestModel
                                      successBlock:^(NSString *requestId, EMSResponseModel *responseModel) {
                                          NSString *html = [[NSString alloc] initWithData:responseModel.body
                                                                                 encoding:NSUTF8StringEncoding];
                                          if (html) {
                                              [weakSelf.meInApp showMessage:[[MEInAppMessage alloc] initWithCampaignId:inApp[@"campaign_id"]
                                                                                                                 sid:[userInfo messageId]
                                                                                                                 url:inApp[@"url"]
                                                                                                                html:html
                                                                                                   responseTimestamp:responseTimestamp]
                                                        completionHandler:nil];
                                          }
                                      }

                                        errorBlock:^(NSString *requestId, NSError *error) {
                                            NSMutableDictionary *parameterDictionary = [NSMutableDictionary new];
                                            parameterDictionary[@"userInfo"] = userInfo;
                                            parameterDictionary[@"inApp"] = inApp;
                                            NSMutableDictionary *statusDictionary = [NSMutableDictionary new];
                                            statusDictionary[@"requestModel"] = requestModel.description;
                                            statusDictionary[@"requestId"] = requestId;
                                            statusDictionary[@"error"] = [error localizedDescription];
                                            EMSStatusLog *log = [[EMSStatusLog alloc] initWithClass:self.class
                                                                                                sel:_cmd
                                                                                         parameters:parameterDictionary
                                                                                             status:statusDictionary];

                                            EMSLog(log, LogLevelError);
                                        }];
    }
}

@end