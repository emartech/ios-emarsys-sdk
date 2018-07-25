//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MEUserNotificationDelegate.h"
#import "MobileEngageInternal.h"
#import <UserNotifications/UNNotificationResponse.h>
#import <UserNotifications/UNNotification.h>
#import <UserNotifications/UNNotificationContent.h>
#import <UserNotifications/UNNotificationRequest.h>
#import "MEExperimental.h"
#import "EMSDictionaryValidator.h"
#import "MEInApp+Private.h"

@interface MEUserNotificationDelegate ()

@property(nonatomic, strong) UIApplication *application;
@property(nonatomic, strong) MobileEngageInternal *mobileEngage;
@property(nonatomic, strong) MEInApp *inApp;

@end

@implementation MEUserNotificationDelegate

@synthesize delegate = _delegate;
@synthesize eventHandler = _eventHandler;

- (instancetype)initWithApplication:(UIApplication *)application
               mobileEngageInternal:(MobileEngageInternal *)mobileEngage
                              inApp:(id <MEIAMProtocol>)inApp {
    NSParameterAssert(application);
    NSParameterAssert(mobileEngage);
    NSParameterAssert(inApp);
    if (self = [super init]) {
        _application = application;
        _mobileEngage = mobileEngage;
        _inApp = inApp;
    }
    return self;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    if (self.delegate) {
        [self.delegate userNotificationCenter:center
                      willPresentNotification:notification
                        withCompletionHandler:completionHandler];
    }
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    if (self.delegate) {
        [self.delegate userNotificationCenter:center
               didReceiveNotificationResponse:response
                        withCompletionHandler:completionHandler];
    }
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSDictionary *inApp = userInfo[@"ems"][@"inapp"];
    if (inApp) {
        NSArray *errors = [inApp validate:^(EMSDictionaryValidator *validate) {
            [validate valueExistsForKey:@"inAppData" withType:[NSData class]];
            [validate valueExistsForKey:@"campaign_id" withType:[NSString class]];
        }];
        if ([errors count] == 0) {
            NSString *html = [[NSString alloc] initWithData:inApp[@"inAppData"]
                                                   encoding:NSUTF8StringEncoding];
            [self.inApp showMessage:[[MEInAppMessage alloc] initWithCampaignId:inApp[@"campaign_id"]
                                                                          html:html]
                  completionHandler:nil];
        }
    }

    [self.mobileEngage trackMessageOpenWithUserInfo:userInfo];
    NSDictionary *action = [self actionFromResponse:response];
    if (action) {
        if ([MEExperimental isFeatureEnabled:INAPP_MESSAGING] || [MEExperimental isFeatureEnabled:USER_CENTRIC_INBOX]) {
            [self.mobileEngage trackInternalCustomEvent:@"richNotification:actionClicked"
                                        eventAttributes:@{
                                            @"button_id": action[@"id"],
                                            @"title": action[@"title"]
                                        }];
        }
        NSString *type = action[@"type"];
        if ([type isEqualToString:@"MEAppEvent"]) {
            [self.eventHandler handleEvent:action[@"name"]
                                   payload:action[@"payload"]];
        } else if ([type isEqualToString:@"OpenExternalUrl"]) {
            [self.application openURL:[NSURL URLWithString:action[@"url"]]
                              options:@{}
                    completionHandler:nil];
        } else if ([type isEqualToString:@"MECustomEvent"]) {
            [self.mobileEngage trackCustomEvent:action[@"name"]
                                eventAttributes:action[@"payload"]];
        }
    }
    completionHandler();
}

- (NSDictionary *)actionFromResponse:(UNNotificationResponse *)response {
    NSDictionary *action;
    for (NSDictionary *actionDict in response.notification.request.content.userInfo[@"ems"][@"actions"]) {
        if ([response.actionIdentifier isEqualToString:actionDict[@"id"]]) {
            action = actionDict;
            break;
        }
    }
    return action;
}

@end
