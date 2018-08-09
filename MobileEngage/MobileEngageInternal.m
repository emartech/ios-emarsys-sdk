//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MobileEngageInternal.h"
#import "MobileEngageStatusDelegate.h"
#import "MEConfig.h"
#import "NSDictionary+MobileEngage.h"
#import "NSError+EMSCore.h"
#import "MEDefaultHeaders.h"
#import "AbstractResponseHandler.h"
#import "MEIdResponseHandler.h"
#import "MEIAMResponseHandler.h"
#import "MEExperimental.h"
#import "MEButtonClickRepository.h"
#import "MobileEngage.h"
#import "MobileEngage+Private.h"
#import "MEDisplayedIAMRepository.h"
#import "MEIAMCleanupResponseHandler.h"
#import "MENotificationCenterManager.h"
#import "MERequestContext.h"
#import "MERequestFactory.h"
#import "MERequestModelRepositoryFactory.h"
#import "MELogRepository.h"
#import <UIKit/UIKit.h>

@interface MobileEngageInternal ()

@property(nonatomic, strong) MEConfig *config;
@property(nonatomic, strong) NSArray<AbstractResponseHandler *> *responseHandlers;

@end

@implementation MobileEngageInternal

- (void) setupWithConfig:(nonnull MEConfig *)config
           launchOptions:(NSDictionary *)launchOptions
requestRepositoryFactory:(MERequestModelRepositoryFactory *)requestRepositoryFactory
         shardRepository:(id <EMSShardRepositoryProtocol>)shardRepository
           logRepository:(MELogRepository *)logRepository
          requestContext:(MERequestContext *)requestContext {
    NSParameterAssert(requestRepositoryFactory);
    __weak typeof(self) weakSelf = self;
    _successBlock = ^(NSString *requestId, EMSResponseModel *responseModel) {
        [weakSelf handleResponse:responseModel];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.statusDelegate respondsToSelector:@selector(mobileEngageLogReceivedWithEventId:log:)]) {
                [weakSelf.statusDelegate mobileEngageLogReceivedWithEventId:requestId
                                                                        log:@"Success"];
            }
        });
    };
    _errorBlock = ^(NSString *requestId, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.statusDelegate respondsToSelector:@selector(mobileEngageErrorHappenedWithEventId:error:)]) {
                [weakSelf.statusDelegate mobileEngageErrorHappenedWithEventId:requestId
                                                                        error:error];
            }
        });
    };

    const BOOL shouldBatch = [MEExperimental isFeatureEnabled:INAPP_MESSAGING] || [MEExperimental isFeatureEnabled:USER_CENTRIC_INBOX];
    const id <EMSRequestModelRepositoryProtocol> requestRepository = [requestRepositoryFactory createWithBatchCustomEventProcessing:shouldBatch];
    EMSRequestManager *manager = [EMSRequestManager managerWithSuccessBlock:self.successBlock
                                                                 errorBlock:self.errorBlock
                                                          requestRepository:requestRepository
                                                            shardRepository:shardRepository
                                                              logRepository:logRepository];
    [self setupWithRequestManager:manager
                           config:config
                    launchOptions:launchOptions
                   requestContext:requestContext];
}


- (void)setupWithRequestManager:(EMSRequestManager *)requestManager
                         config:(nonnull MEConfig *)config
                  launchOptions:(NSDictionary *)launchOptions
                 requestContext:(MERequestContext *)requestContext {
    _requestContext = requestContext;
    _requestManager = requestManager;
    _config = config;
    [requestManager setAdditionalHeaders:[MEDefaultHeaders additionalHeadersWithConfig:self.config]];

    NSMutableArray *responseHandlers = [NSMutableArray array];
    if ([MEExperimental isFeatureEnabled:INAPP_MESSAGING] || [MEExperimental isFeatureEnabled:USER_CENTRIC_INBOX]) {
        [responseHandlers addObject:[[MEIdResponseHandler alloc] initWithRequestContext:_requestContext]];
    }
    if ([MEExperimental isFeatureEnabled:INAPP_MESSAGING]) {
        [responseHandlers addObjectsFromArray:@[
                [MEIAMResponseHandler new],
                [[MEIAMCleanupResponseHandler alloc] initWithButtonClickRepository:[[MEButtonClickRepository alloc] initWithDbHelper:[MobileEngage dbHelper]]
                                                              displayIamRepository:[[MEDisplayedIAMRepository alloc] initWithDbHelper:[MobileEngage dbHelper]]]]
        ];
    }
    _responseHandlers = [NSArray arrayWithArray:responseHandlers];

    __weak typeof(self) weakSelf = self;
    [_notificationCenterManager addHandlerBlock:^{
        if (self.requestContext.meId != nil) {
            [weakSelf.requestManager submit:[MERequestFactory createCustomEventModelWithEventName:@"app:start"
                                                                                  eventAttributes:nil
                                                                                             type:@"internal"
                                                                                   requestContext:weakSelf.requestContext]];
        }
    }                           forNotification:UIApplicationDidBecomeActiveNotification];
}

- (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(nullable MESourceHandler)sourceHandler {
    BOOL result = NO;
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSString *const webPageURL = userActivity.webpageURL.absoluteString;
        NSString *const queryNameDeepLink = @"ems_dl";
        NSURLQueryItem *queryItem = [self extractQueryItemFromUrl:webPageURL
                                                        queryName:queryNameDeepLink];
        if (queryItem) {
            result = YES;
            if (sourceHandler) {
                sourceHandler(webPageURL);
            }
            [self.requestManager submit:[MERequestFactory createTrackDeepLinkRequestWithTrackingId:queryItem.value ? queryItem.value : @""
                                                                                    requestContext:self.requestContext]];
        }
    }
    return result;
}

- (NSURLQueryItem *)extractQueryItemFromUrl:(NSString *const)webPageURL
                                  queryName:(NSString *const)queryName {
    NSURLQueryItem *result;
    for (NSURLQueryItem *queryItem in [[NSURLComponents componentsWithString:webPageURL] queryItems]) {
        if ([queryItem.name isEqualToString:queryName]) {
            result = queryItem;
            break;
        }
    }
    return result;
}


- (void)trackInAppDisplay:(NSString *)campaignId {
    [self.requestManager submit:[MERequestFactory createCustomEventModelWithEventName:@"inapp:viewed"
                                                                      eventAttributes:@{@"message_id": campaignId}
                                                                                 type:@"internal"
                                                                       requestContext:self.requestContext]];
}

- (void)trackInAppClick:(NSString *)campaignId buttonId:(NSString *)buttonId {
    [self.requestManager submit:[MERequestFactory createCustomEventModelWithEventName:@"inapp:click"
                                                                      eventAttributes:@{
                                                                              @"message_id": campaignId,
                                                                              @"button_id": buttonId
                                                                      }
                                                                                 type:@"internal"
                                                                       requestContext:self.requestContext]];
}

- (void)handleResponse:(EMSResponseModel *)model {
    for (AbstractResponseHandler *handler in _responseHandlers) {
        [handler processResponse:model];
    }
}

- (void)setPushToken:(NSData *)pushToken {
    _pushToken = pushToken;

    if (self.requestContext.appLoginParameters != nil) {
        [self appLoginWithContactFieldId:self.requestContext.appLoginParameters.contactFieldId
                       contactFieldValue:self.requestContext.appLoginParameters.contactFieldValue];
    }
}

- (NSString *)appLogin {
    return [self appLoginWithContactFieldId:nil
                          contactFieldValue:nil];
}

- (NSString *)appLoginWithContactFieldId:(NSNumber *)contactFieldId
                       contactFieldValue:(NSString *)contactFieldValue {
    self.requestContext.appLoginParameters = [MEAppLoginParameters parametersWithContactFieldId:contactFieldId
                                                                              contactFieldValue:contactFieldValue];

    EMSRequestModel *requestModel = [MERequestFactory createLoginOrLastMobileActivityRequestWithPushToken:self.pushToken
                                                                                           requestContext:self.requestContext];
    [self.requestManager submit:requestModel];
    return requestModel.requestId;
}


- (NSString *)appLogout {
    EMSRequestModel *requestModel = [MERequestFactory createAppLogoutRequestWithRequestContext:self.requestContext];
    [self.requestManager submit:requestModel];
    [self.requestContext reset];
    return requestModel.requestId;
}

- (NSString *)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo {
    NSString *messageId = [userInfo messageId];
    EMSRequestModel *requestModel = [MERequestFactory createTrackMessageOpenRequestWithMessageId:messageId
                                                                                  requestContext:self.requestContext];
    if (messageId) {
        [self.requestManager submit:requestModel];
    } else {
        self.errorBlock(requestModel.requestId, [NSError errorWithCode:1
                                                  localizedDescription:@"Missing messageId"]);
    }
    return requestModel.requestId;
}

- (NSString *)trackMessageOpenWithInboxMessage:(MENotification *)inboxMessage {
    NSParameterAssert(inboxMessage);
    EMSRequestModel *requestModel;
    if ([MEExperimental isFeatureEnabled:USER_CENTRIC_INBOX]) {
        requestModel = [MERequestFactory createTrackMessageOpenRequestWithNotification:inboxMessage
                                                                        requestContext:self.requestContext];
        if (!inboxMessage.id) {
            self.errorBlock(requestModel.requestId, [NSError errorWithCode:1
                                                      localizedDescription:@"Missing messageId"]);
        } else if (!inboxMessage.sid) {
            self.errorBlock(requestModel.requestId, [NSError errorWithCode:1
                                                      localizedDescription:@"Missing sid"]);
        } else {
            [self.requestManager submit:requestModel];
        }
    } else {
        requestModel = [MERequestFactory createTrackMessageOpenRequestWithNotification:inboxMessage
                                                                        requestContext:self.requestContext];
        [self.requestManager submit:requestModel];
    }
    return [requestModel requestId];
}

- (NSString *)trackCustomEvent:(nonnull NSString *)eventName
               eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes {
    NSParameterAssert(eventName);

    EMSRequestModel *requestModel = [MERequestFactory createTrackCustomEventRequestWithEventName:eventName
                                                                                 eventAttributes:eventAttributes
                                                                                  requestContext:self.requestContext];
    [self.requestManager submit:requestModel];
    return requestModel.requestId;
}

- (NSString *)trackInternalCustomEvent:(NSString *)eventName
                       eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes {
    NSParameterAssert(eventName);
    EMSRequestModel *requestModel = [MERequestFactory createCustomEventModelWithEventName:eventName
                                                                          eventAttributes:eventAttributes
                                                                                     type:@"internal"
                                                                           requestContext:self.requestContext];
    [self.requestManager submit:requestModel];
    return requestModel.requestId;
}


@end
