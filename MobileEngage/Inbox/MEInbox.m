//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSError+EMSCore.h"
#import "MEInbox.h"
#import "MEDefaultHeaders.h"
#import "MEInboxParser.h"
#import "EMSRequestModelBuilder.h"
#import "EMSResponseModel.h"
#import "EMSDeviceInfo.h"
#import "EMSRESTClient.h"
#import "EMSAuthentication.h"
#import "MERequestFactory.h"
#import "EMSRequestManager.h"
#import "EMSNotificationCache.h"

@interface MEInbox ()

@property(nonatomic, strong) EMSRESTClient *restClient;
@property(nonatomic, strong) EMSConfig *config;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSNotificationCache *notificationCache;

@end

@implementation MEInbox

#pragma mark - Init

- (instancetype)initWithConfig:(EMSConfig *)config
                requestContext:(MERequestContext *)requestContext
             notificationCache:(EMSNotificationCache *)notificationCache
                    restClient:(EMSRESTClient *)restClient
                requestManager:(EMSRequestManager *)requestManager {
    NSParameterAssert(config);
    NSParameterAssert(requestContext);
    NSParameterAssert(notificationCache);
    NSParameterAssert(restClient);
    NSParameterAssert(requestManager);
    if (self = [super init]) {
        _config = config;
        _requestContext = requestContext;
        _notificationCache = notificationCache;
        _restClient = restClient;
        _requestManager = requestManager;
    }
    return self;
}

#pragma mark - Public methods

- (void)fetchNotificationsWithResultBlock:(EMSFetchNotificationResultBlock)resultBlock {
    NSParameterAssert(resultBlock);
    if ([self hasLoginParameters]) {
        __weak typeof(self) weakSelf = self;
        EMSRequestModel *request = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                NSDictionary *headers = [weakSelf createNotificationsFetchingHeaders];
                [[[builder setMethod:HTTPMethodGET] setHeaders:headers] setUrl:@"https://me-inbox.eservice.emarsys.net/api/notifications"];
            }
                                                  timestampProvider:self.requestContext.timestampProvider
                                                       uuidProvider:self.requestContext.uuidProvider];
        [_restClient executeTaskWithRequestModel:request
                                    successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:response.body
                                                                                                options:0
                                                                                                  error:nil];
                                        EMSNotificationInboxStatus *status = [[MEInboxParser new] parseNotificationInboxStatus:payload];
                                        status.notifications = [weakSelf.notificationCache mergeWithNotifications:status.notifications];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if (resultBlock) {
                                                resultBlock(status, nil);
                                            }
                                        });
                                    }
                                      errorBlock:^(NSString *requestId, NSError *error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              if (resultBlock) {
                                                  resultBlock(nil, error);
                                              }
                                          });
                                      }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resultBlock) {
                resultBlock(nil, [NSError errorWithCode:42
                                   localizedDescription:@"Login parameters are not available."]);
            }
        });
    }
}


- (void)resetBadgeCount {
    [self resetBadgeCountWithCompletionBlock:nil];
}

- (void)resetBadgeCountWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    if ([self hasLoginParameters]) {
        EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://me-inbox.eservice.emarsys.net/api/reset-badge-count"];
                [builder setMethod:HTTPMethodPOST];
                [builder setHeaders:[self createNotificationsFetchingHeaders]];
            }
                                                timestampProvider:self.requestContext.timestampProvider
                                                     uuidProvider:self.requestContext.uuidProvider];
        [_restClient executeTaskWithRequestModel:model
                                    successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if (completionBlock) {
                                                completionBlock(nil);
                                            }
                                        });
                                    }
                                      errorBlock:^(NSString *requestId, NSError *error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              if (completionBlock) {
                                                  completionBlock(error);
                                              }
                                          });
                                      }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock([NSError errorWithCode:42
                                  localizedDescription:@"Login parameters are not available."]);
            }
        });
    }
}

- (void)trackNotificationOpenWithNotification:(EMSNotification *)inboxNotification {
    [self trackMessageOpenWith:inboxNotification
               completionBlock:nil];
}

- (void)trackMessageOpenWith:(EMSNotification *)inboxNotification
             completionBlock:(EMSCompletionBlock)completionBlock {
    NSParameterAssert(inboxNotification);
    EMSRequestModel *requestModel;

    requestModel = [MERequestFactory createTrackMessageOpenRequestWithNotification:inboxNotification
                                                                    requestContext:self.requestContext];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:completionBlock];;
}

- (void)purgeNotificationCache {
}


#pragma mark - Private methods

- (NSDictionary<NSString *, NSString *> *)createNotificationsFetchingHeaders {
    NSDictionary *defaultHeaders = [MEDefaultHeaders additionalHeadersWithConfig:self.config];
    NSMutableDictionary *mutableFetchingHeaders = [NSMutableDictionary dictionaryWithDictionary:defaultHeaders];
    mutableFetchingHeaders[@"x-ems-me-hardware-id"] = [EMSDeviceInfo hardwareId];
    mutableFetchingHeaders[@"x-ems-me-application-code"] = self.config.applicationCode;
    mutableFetchingHeaders[@"x-ems-me-contact-field-id"] = [NSString stringWithFormat:@"%@",
                                                                                      self.requestContext.appLoginParameters.contactFieldId];
    mutableFetchingHeaders[@"x-ems-me-contact-field-value"] = self.requestContext.appLoginParameters.contactFieldValue;
    mutableFetchingHeaders[@"Authorization"] = [EMSAuthentication createBasicAuthWithUsername:self.config.applicationCode
                                                                                     password:self.config.applicationPassword];
    return [NSDictionary dictionaryWithDictionary:mutableFetchingHeaders];
}

- (BOOL)hasLoginParameters {
    return self.requestContext.appLoginParameters && self.requestContext.appLoginParameters.contactFieldId && self.requestContext.appLoginParameters.contactFieldValue;
}

@end
