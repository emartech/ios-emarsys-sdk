//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MEUserNotificationDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "EMSDictionaryValidator.h"
#import "MEInAppMessage.h"
#import "MEInApp.h"
#import "NSDictionary+MobileEngage.h"
#import "EMSTimestampProvider.h"
#import "EMSMacros.h"
#import "EMSCrashLog.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "EMSPushNotificationProtocol.h"
#import "EMSMobileEngageProtocol.h"

@interface MEUserNotificationDelegate ()

@property(nonatomic, strong) UIApplication *application;
@property(nonatomic, strong) id <EMSMobileEngageProtocol> mobileEngage;
@property(nonatomic, strong) MEInApp *inApp;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) id <EMSPushNotificationProtocol> pushInternal;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSRequestFactory *requestFactory;

@end

@implementation MEUserNotificationDelegate

@synthesize delegate = _delegate;
@synthesize eventHandler = _eventHandler;

- (instancetype)initWithApplication:(UIApplication *)application
               mobileEngageInternal:(id <EMSMobileEngageProtocol>)mobileEngage
                              inApp:(MEInApp *)inApp
                  timestampProvider:(EMSTimestampProvider *)timestampProvider
                       uuidProvider:(EMSUUIDProvider *)uuidProvider
                       pushInternal:(id <EMSPushNotificationProtocol>)pushInternal
                     requestManager:(EMSRequestManager *)requestManager
                     requestFactory:(EMSRequestFactory *)requestFactory {
    NSParameterAssert(application);
    NSParameterAssert(mobileEngage);
    NSParameterAssert(inApp);
    NSParameterAssert(timestampProvider);
    NSParameterAssert(uuidProvider);
    NSParameterAssert(pushInternal);
    NSParameterAssert(requestManager);
    NSParameterAssert(requestFactory);
    if (self = [super init]) {
        _application = application;
        _mobileEngage = mobileEngage;
        _inApp = inApp;
        _timestampProvider = timestampProvider;
        _uuidProvider = uuidProvider;
        _pushInternal = pushInternal;
        _requestManager = requestManager;
        _requestFactory = requestFactory;
    }
    return self;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler NS_AVAILABLE_IOS(10_0) {
    if (self.delegate) {
        [self.delegate userNotificationCenter:center
                      willPresentNotification:notification
                        withCompletionHandler:completionHandler];
    }
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler NS_AVAILABLE_IOS(10_0) {
    if (self.delegate) {
        [self.delegate userNotificationCenter:center
               didReceiveNotificationResponse:response
                        withCompletionHandler:completionHandler];
    }
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[@"exception"]) {
        EMSLog([[EMSCrashLog alloc] initWithException:userInfo[@"exception"]]);
    }
    NSDictionary *inApp = userInfo[@"ems"][@"inapp"];
    if (inApp) {
        [self handleInApp:userInfo
                    inApp:inApp];
    }

    NSDictionary *action = [self actionFromResponse:response];
    if (action && action[@"id"]) {
        EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"push:click"
                                                                                  eventAttributes:@{
                                                                                          @"origin": @"button",
                                                                                          @"button_id": action[@"id"],
                                                                                          @"sid": [userInfo messageId]
                                                                                  } eventType:EventTypeInternal];
        [self.requestManager submitRequestModel:requestModel
                            withCompletionBlock:nil];
    } else {
        [self.pushInternal trackMessageOpenWithUserInfo:userInfo];
    }
    if (action) {
        [self handleAction:action];
    }
    completionHandler();
}

- (void)handleAction:(NSDictionary *)action {
    NSString *type = action[@"type"];
    if ([type isEqualToString:@"MEAppEvent"]) {
        [self.eventHandler handleEvent:action[@"name"]
                               payload:action[@"payload"]];
    } else if ([type isEqualToString:@"OpenExternalUrl"]) {
        [self.application openURL:[NSURL URLWithString:action[@"url"]]
                          options:@{}
                completionHandler:nil];
    } else if ([type isEqualToString:@"MECustomEvent"]) {
        [self.mobileEngage trackCustomEventWithName:action[@"name"]
                                    eventAttributes:action[@"payload"]
                                    completionBlock:nil];
    }
}

- (void)handleInApp:(NSDictionary *)userInfo
              inApp:(NSDictionary *)inApp {
    NSDate *responseTimestamp = [self.timestampProvider provideTimestamp];
    NSArray *errors = [inApp validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"inAppData" withType:[NSData class]];
        [validate valueExistsForKey:@"campaign_id" withType:[NSString class]];
    }];
    if ([errors count] == 0) {
        NSString *html = [[NSString alloc] initWithData:inApp[@"inAppData"]
                                               encoding:NSUTF8StringEncoding];
        [self.inApp showMessage:[[MEInAppMessage alloc] initWithCampaignId:inApp[@"campaign_id"]
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
                                              [weakSelf.inApp showMessage:[[MEInAppMessage alloc] initWithCampaignId:inApp[@"campaign_id"]
                                                                                                                 sid:[userInfo messageId]
                                                                                                                 url:inApp[@"url"]
                                                                                                                html:html
                                                                                                   responseTimestamp:responseTimestamp]
                                                        completionHandler:nil];
                                          }
                                      }
                                        errorBlock:^(NSString *requestId, NSError *error) {
                                        }];
    }
}

- (NSDictionary *)actionFromResponse:(UNNotificationResponse *)response NS_AVAILABLE_IOS(10_0) {
    NSDictionary *ems = response.notification.request.content.userInfo[@"ems"];
    NSDictionary *action;
    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        action = ems[@"default_action"];
    }
    for (NSDictionary *actionDict in ems[@"actions"]) {
        if ([response.actionIdentifier isEqualToString:actionDict[@"id"]]) {
            action = actionDict;
            break;
        }
    }
    return action;
}

@end
