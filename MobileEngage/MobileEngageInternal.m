//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MobileEngageInternal.h"
#import "EMSConfig.h"
#import "NSDictionary+MobileEngage.h"
#import "NSError+EMSCore.h"
#import "MEDefaultHeaders.h"
#import "EMSAbstractResponseHandler.h"
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
#import <UIKit/UIKit.h>

@interface MobileEngageInternal ()

@property(nonatomic, strong) EMSConfig *config;
@property(nonatomic, strong) NSArray<EMSAbstractResponseHandler *> *responseHandlers;

@end

@implementation MobileEngageInternal

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestContext:(MERequestContext *)requestContext
             notificationCenterManager:(MENotificationCenterManager *)notificationCenterManager {
    if (self = [super init]) {
        [self setupWithRequestManager:requestManager
                               config:requestContext.config
                        launchOptions:nil
                       requestContext:requestContext
            notificationCenterManager:notificationCenterManager];
    }
    return self;
}

//- (void) setupWithConfig:(nonnull EMSConfig *)config
//           launchOptions:(NSDictionary *)launchOptions
//requestRepositoryFactory:(MERequestModelRepositoryFactory *)requestRepositoryFactory
//         shardRepository:(id <EMSShardRepositoryProtocol>)shardRepository
//           logRepository:(MELogRepository *)logRepository
//          requestContext:(MERequestContext *)requestContext {
//    NSParameterAssert(requestRepositoryFactory);
//    __weak typeof(self) weakSelf = self;
//    _successBlock = ^(NSString *requestId, EMSResponseModel *responseModel) {
//        [weakSelf handleResponse:responseModel];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([weakSelf.statusDelegate respondsToSelector:@selector(mobileEngageLogReceivedWithEventId:log:)]) {
//                [weakSelf.statusDelegate mobileEngageLogReceivedWithEventId:requestId
//                                                                        log:@"Success"];
//            }
//        });
//    };
//    _errorBlock = ^(NSString *requestId, NSError *error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([weakSelf.statusDelegate respondsToSelector:@selector(mobileEngageErrorHappenedWithEventId:error:)]) {
//                [weakSelf.statusDelegate mobileEngageErrorHappenedWithEventId:requestId
//                                                                        error:error];
//            }
//        });
//    };
//
//    const BOOL shouldBatch = [MEExperimental isFeatureEnabled:INAPP_MESSAGING] || [MEExperimental isFeatureEnabled:USER_CENTRIC_INBOX];
//    const id <EMSRequestModelRepositoryProtocol> requestRepository = [requestRepositoryFactory createWithBatchCustomEventProcessing:shouldBatch];
//    EMSRequestManager *manager = [EMSRequestManager managerWithSuccessBlock:self.successBlock
//                                                                 errorBlock:self.errorBlock
//                                                          requestRepository:requestRepository
//                                                            shardRepository:shardRepository
//                                                              logRepository:logRepository];
//    [self setupWithRequestManager:manager
//                           config:config
//                    launchOptions:launchOptions
//                   requestContext:requestContext];
//}
//
//- (void)setupWithRequestManager:(EMSRequestManager *)requestManager
//                 requestContext:(MERequestContext *)requestContext {
//    [self setupWithRequestManager:requestManager
//                           config:requestContext.config
//                    launchOptions:nil
//                   requestContext:requestContext];
//}


- (void)setupWithRequestManager:(EMSRequestManager *)requestManager
                         config:(nonnull EMSConfig *)config
                  launchOptions:(NSDictionary *)launchOptions
                 requestContext:(MERequestContext *)requestContext
      notificationCenterManager:(MENotificationCenterManager *)notificationCenterManager {
    _requestContext = requestContext;
    _requestManager = requestManager;
    _config = config;
    _notificationCenterManager = notificationCenterManager;
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
            [weakSelf.requestManager submitRequestModel:[MERequestFactory createCustomEventModelWithEventName:@"app:start"
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
            [self.requestManager submitRequestModel:[MERequestFactory createTrackDeepLinkRequestWithTrackingId:queryItem.value ? queryItem.value : @""
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
    [self.requestManager submitRequestModel:[MERequestFactory createCustomEventModelWithEventName:@"inapp:viewed"
                                                                                  eventAttributes:@{@"message_id": campaignId}
                                                                                             type:@"internal"
                                                                                   requestContext:self.requestContext]];
}

- (void)trackInAppClick:(NSString *)campaignId buttonId:(NSString *)buttonId {
    [self.requestManager submitRequestModel:[MERequestFactory createCustomEventModelWithEventName:@"inapp:click"
                                                                                  eventAttributes:@{
                                                                                          @"message_id": campaignId,
                                                                                          @"button_id": buttonId
                                                                                  }
                                                                                             type:@"internal"
                                                                                   requestContext:self.requestContext]];
}

- (void)handleResponse:(EMSResponseModel *)model {
    for (EMSAbstractResponseHandler *handler in _responseHandlers) {
        [handler processResponse:model];
    }
}

- (void)setPushToken:(NSData *)pushToken {
    _pushToken = pushToken;

    if (self.requestContext.appLoginParameters != nil) {
        [self appLoginWithContactFieldValue:self.requestContext.appLoginParameters.contactFieldValue];
    }
}

- (NSString *)appLogin {
    return [self appLoginWithContactFieldValue:nil];
}

- (NSString *)appLoginWithContactFieldValue:(NSString *)contactFieldValue {
    self.requestContext.appLoginParameters = [MEAppLoginParameters parametersWithContactFieldId:self.requestContext.contactFieldId
                                                                              contactFieldValue:contactFieldValue];

    EMSRequestModel *requestModel = [MERequestFactory createLoginOrLastMobileActivityRequestWithPushToken:self.pushToken
                                                                                           requestContext:self.requestContext];
    [self.requestManager submitRequestModel:requestModel];
    return requestModel.requestId;
}


- (NSString *)appLogout {
    EMSRequestModel *requestModel = [MERequestFactory createAppLogoutRequestWithRequestContext:self.requestContext];
    [self.requestManager submitRequestModel:requestModel];
    [self.requestContext reset];
    return requestModel.requestId;
}

- (NSString *)trackMessageOpenWithUserInfoWithReturn:(NSDictionary *)userInfo {
    NSString *messageId = [userInfo messageId];
    EMSRequestModel *requestModel = [MERequestFactory createTrackMessageOpenRequestWithMessageId:messageId
                                                                                  requestContext:self.requestContext];
    if (messageId) {
        [self.requestManager submitRequestModel:requestModel];
    } else {
        self.errorBlock(requestModel.requestId, [NSError errorWithCode:1
                                                  localizedDescription:@"Missing messageId"]);
    }
    return requestModel.requestId;
}

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo {
    [self trackMessageOpenWith:userInfo
               completionBlock:nil];
}

- (void)trackMessageOpenWith:(NSDictionary *)userInfo
             completionBlock:(EMSCompletionBlock)completionBlock {
    NSString *messageId = [userInfo messageId];
    if (messageId) {
        EMSRequestModel *requestModel = [MERequestFactory createTrackMessageOpenRequestWithMessageId:messageId
                                                                                      requestContext:self.requestContext];
        [self.requestManager submitRequestModel:requestModel];
    } else {
        completionBlock([NSError errorWithCode:1
                          localizedDescription:@"Missing messageId"]);
    }
}


- (NSString *)trackCustomEvent:(nonnull NSString *)eventName
               eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes {
    NSParameterAssert(eventName);

    EMSRequestModel *requestModel = [MERequestFactory createTrackCustomEventRequestWithEventName:eventName
                                                                                 eventAttributes:eventAttributes
                                                                                  requestContext:self.requestContext];
    [self.requestManager submitRequestModel:requestModel];
    return requestModel.requestId;
}

- (NSString *)trackInternalCustomEvent:(NSString *)eventName
                       eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes {
    NSParameterAssert(eventName);
    EMSRequestModel *requestModel = [MERequestFactory createCustomEventModelWithEventName:eventName
                                                                          eventAttributes:eventAttributes
                                                                                     type:@"internal"
                                                                           requestContext:self.requestContext];
    [self.requestManager submitRequestModel:requestModel];
    return requestModel.requestId;
}


@end
