//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "EMSPushV3Internal.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "NSData+MobileEngine.h"
#import "NSDictionary+MobileEngage.h"
#import "NSError+EMSCore.h"
#import "EMSTimestampProvider.h"
#import "EMSActionFactory.h"
#import "EMSActionProtocol.h"
#import "EMSNotificationInformation.h"
#import "EMSUUIDProvider.h"
#import "EMSMacros.h"
#import "EMSCrashLog.h"
#import "EMSStatusLog.h"
#import "EMSDictionaryValidator.h"

#define kEMSPushTokenKey @"EMSPushTokenKey"

@interface EMSPushV3Internal ()

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSActionFactory *actionFactory;
@property(nonatomic, strong) EMSStorage *storage;
@property(nonatomic, strong) MEInApp *inApp;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation EMSPushV3Internal

@synthesize delegate = _delegate;

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                     timestampProvider:(EMSTimestampProvider *)timestampProvider
                         actionFactory:(EMSActionFactory *)actionFactory
                               storage:(EMSStorage *)storage
                                 inApp:(MEInApp *)inApp
                          uuidProvider:(EMSUUIDProvider *)uuidProvider
                        operationQueue:(NSOperationQueue *)operationQueue {
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestManager);
    NSParameterAssert(timestampProvider);
    NSParameterAssert(actionFactory);
    NSParameterAssert(storage);
    NSParameterAssert(inApp);
    NSParameterAssert(uuidProvider);
    NSParameterAssert(operationQueue);
    if (self = [super init]) {
        _requestFactory = requestFactory;
        _requestManager = requestManager;
        _timestampProvider = timestampProvider;
        _actionFactory = actionFactory;
        _storage = storage;
        _deviceToken = [storage dataForKey:kEMSPushTokenKey];
        _inApp = inApp;
        _uuidProvider = uuidProvider;
        _operationQueue = operationQueue;
    }
    return self;
}

- (void)clearDeviceTokenStorage {
    [self.storage setData:nil
                   forKey:kEMSPushTokenKey];
}

- (void)setPushToken:(NSData *)pushToken {
    [self setPushToken:pushToken
       completionBlock:nil];
}

- (void)setPushToken:(NSData *)pushToken
     completionBlock:(EMSCompletionBlock)completionBlock {
    NSData *storedToken = [self.storage dataForKey:kEMSPushTokenKey];
    if (storedToken && storedToken == pushToken) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
    } else {
        _deviceToken = pushToken;
        NSString *deviceToken = [self.deviceToken deviceTokenString];
        EMSRequestModel *requestModel;
        if (deviceToken && [deviceToken length] > 0) {
            requestModel = [self.requestFactory createPushTokenRequestModelWithPushToken:deviceToken];
            [self.requestManager submitRequestModel:requestModel
                                withCompletionBlock:^(NSError *error) {
                                    if (!error) {
                                        [self.storage setData:pushToken
                                                       forKey:kEMSPushTokenKey];
                                    }
                                    if (completionBlock) {
                                        completionBlock(error);
                                    }
                                }];
        }
    }
}

- (nullable NSData *)pushToken {
    return self.deviceToken;
}

- (void)clearPushToken {
    [self clearPushTokenWithCompletionBlock:nil];
}

- (void)clearPushTokenWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    _deviceToken = nil;
    [self.storage setData:nil
                   forKey:kEMSPushTokenKey];
    EMSRequestModel *requestModel = [self.requestFactory createClearPushTokenRequestModel];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:completionBlock];
}

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo {
    [self trackMessageOpenWithUserInfo:userInfo
                       completionBlock:nil];
}

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo
                     completionBlock:(EMSCompletionBlock)completionBlock {
    NSParameterAssert(userInfo);

    NSString *sid = [userInfo messageId];
    if (sid) {
        EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"push:click"
                                                                                  eventAttributes:@{
                                                                                          @"origin": @"main",
                                                                                          @"sid": sid
                                                                                  }
                                                                                        eventType:EventTypeInternal];
        [self.requestManager submitRequestModel:requestModel
                            withCompletionBlock:completionBlock];

    } else if (completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock([NSError errorWithCode:1400
                              localizedDescription:@"No messageId found!"]);
        });
    }
}

- (void)handleMessageWithUserInfo:(NSDictionary *)userInfo {
    NSArray<NSDictionary *> *actions = userInfo[@"ems"][@"actions"];
    [self.actionFactory setEventHandler:self.silentMessageEventHandler];
    for (NSDictionary *actionDict in actions) {
        id <EMSActionProtocol> action = [self.actionFactory createActionWithActionDictionary:actionDict];
        [action execute];
    }
    NSString *campaignId = userInfo[@"ems"][@"multichannelId"];
    if (campaignId && self.silentMessageInformationBlock) {
        EMSNotificationInformation *notificationInformation = [[EMSNotificationInformation alloc] initWithCampaignId:campaignId];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.silentMessageInformationBlock(notificationInformation);
        });
    }
}

- (NSDictionary *)actionFromResponse:(UNNotificationResponse *)response {
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

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.delegate) {
            [weakSelf.delegate userNotificationCenter:center
                              willPresentNotification:notification
                                withCompletionHandler:completionHandler];
        }
        completionHandler(UNNotificationPresentationOptionAlert);
    });
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        if (weakSelf.delegate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate userNotificationCenter:center
                           didReceiveNotificationResponse:response
                                    withCompletionHandler:completionHandler];
            });
        }
        NSDictionary *userInfo = response.notification.request.content.userInfo;
        if (userInfo[@"exception"]) {
            EMSLog([[EMSCrashLog alloc] initWithException:userInfo[@"exception"]], LogLevelError);
        }

        NSString *campaignId = userInfo[@"ems"][@"multichannelId"];
        if (campaignId && weakSelf.notificationInformationBlock) {
            EMSNotificationInformation *notificationInformation = [[EMSNotificationInformation alloc] initWithCampaignId:campaignId];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.notificationInformationBlock(notificationInformation);
            });
        }

        NSDictionary *inApp = userInfo[@"ems"][@"inapp"];
        if (inApp) {
            [weakSelf handleInApp:userInfo
                            inApp:inApp];
        }

        NSDictionary *action = [weakSelf actionFromResponse:response];
        if (action && action[@"id"]) {
            EMSRequestModel *requestModel = [weakSelf.requestFactory createEventRequestModelWithEventName:@"push:click"
                                                                                          eventAttributes:@{
                                                                                                  @"origin": @"button",
                                                                                                  @"button_id": action[@"id"],
                                                                                                  @"sid": [userInfo messageId]}
                                                                                                eventType:EventTypeInternal];
            [weakSelf.requestManager submitRequestModel:requestModel
                                    withCompletionBlock:nil];
        } else {
            [self trackMessageOpenWithUserInfo:userInfo];
        }
        if (action) {
            [self handleAction:action];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler();
        });
    }];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
   openSettingsForNotification:(UNNotification *)notification {
    if (@available(iOS 12, *)) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.delegate) {
                [weakSelf.delegate userNotificationCenter:center
                              openSettingsForNotification:notification];
            }
        });
    }
}

- (void)handleAction:(NSDictionary *)actionDict {
    [self.actionFactory setEventHandler:self.notificationEventHandler];
    id <EMSActionProtocol> action = [self.actionFactory createActionWithActionDictionary:actionDict];
    [action execute];
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