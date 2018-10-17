//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSAuthentication.h"
#import "MEInboxV2.h"
#import "MEInboxParser.h"
#import "EMSResponseModel.h"
#import "MEDefaultHeaders.h"
#import "NSError+EMSCore.h"
#import "MERequestFactory.h"

@interface MEInboxV2 ()

@property(nonatomic, strong) EMSRESTClient *restClient;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSConfig *config;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) NSMutableArray *resultBlocks;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, assign) BOOL fetchRequestInProgress;
@property(nonatomic, strong) EMSNotificationCache *notificationCache;

@end

@implementation MEInboxV2

- (instancetype)initWithConfig:(EMSConfig *)config
                requestContext:(MERequestContext *)requestContext
             notificationCache:(EMSNotificationCache *)notificationCache
                    restClient:(EMSRESTClient *)restClient
             timestampProvider:(EMSTimestampProvider *)timestampProvider
                requestManager:(EMSRequestManager *)requestManager {
    NSParameterAssert(config);
    NSParameterAssert(requestContext);
    NSParameterAssert(notificationCache);
    NSParameterAssert(restClient);
    NSParameterAssert(timestampProvider);
    NSParameterAssert(requestManager);
    if (self = [super init]) {
        _config = config;
        _requestContext = requestContext;
        _notificationCache = notificationCache;
        _restClient = restClient;
        _timestampProvider = timestampProvider;
        _requestManager = requestManager;
        _resultBlocks = [NSMutableArray new];
    }
    return self;
}


- (void)fetchNotificationsWithResultBlock:(EMSFetchNotificationResultBlock)resultBlock {
    NSParameterAssert(resultBlock);
    if (self.lastNotificationStatus && [[self.timestampProvider provideTimestamp] timeIntervalSinceDate:self.responseTimestamp] < 60) {
        self.lastNotificationStatus.notifications = [self.notificationCache mergeWithNotifications:self.lastNotificationStatus.notifications];
        resultBlock(self.lastNotificationStatus, nil);
        return;
    } else if (self.fetchRequestInProgress) {
        [self.resultBlocks addObject:[resultBlock copy]];
        return;
    }

    if (self.requestContext.meId) {
        __weak typeof(self) weakSelf = self;
        EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setMethod:HTTPMethodGET];
                [builder setHeaders:[weakSelf createNotificationsFetchingHeaders]];
                [builder setUrl:[NSString stringWithFormat:@"https://me-inbox.eservice.emarsys.net/api/v1/notifications/%@",
                                                           weakSelf.requestContext.meId]];
            }
                                                       timestampProvider:self.requestContext.timestampProvider
                                                            uuidProvider:self.requestContext.uuidProvider];
        self.fetchRequestInProgress = YES;
        [_restClient executeTaskWithRequestModel:requestModel
                                    successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:response.body
                                                                                                options:0
                                                                                                  error:nil];
                                        EMSNotificationInboxStatus *status = [[MEInboxParser new] parseNotificationInboxStatus:payload];
                                        weakSelf.lastNotificationStatus = status;
                                        weakSelf.responseTimestamp = [weakSelf.timestampProvider provideTimestamp];
                                        weakSelf.fetchRequestInProgress = NO;

                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            status.notifications = [weakSelf.notificationCache mergeWithNotifications:status.notifications];
                                            EMSNotificationInboxStatus *inboxStatus = status;
                                            resultBlock(inboxStatus, nil);

                                            for (EMSFetchNotificationResultBlock successBlock in weakSelf.resultBlocks) {
                                                successBlock(inboxStatus, nil);
                                            }
                                            [weakSelf.resultBlocks removeAllObjects];
                                        });
                                    }
                                      errorBlock:^(NSString *requestId, NSError *error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              resultBlock(nil, error);
                                          });
                                          weakSelf.fetchRequestInProgress = NO;

                                          for (EMSFetchNotificationResultBlock errorsBlock in weakSelf.resultBlocks) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  errorsBlock(nil, error);
                                              });
                                          }
                                          [weakSelf.resultBlocks removeAllObjects];
                                      }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resultBlock) {
                resultBlock(nil, [NSError errorWithCode:42 localizedDescription:@"MeId is not available."]);
            }
        });
    }
}

- (void)resetBadgeCountWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    if (self.requestContext.meId) {
        __weak typeof(self) weakSelf = self;
        EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setMethod:HTTPMethodDELETE];
                [builder setHeaders:[weakSelf createNotificationsFetchingHeaders]];
                [builder setUrl:[NSString stringWithFormat:@"https://me-inbox.eservice.emarsys.net/api/v1/notifications/%@/count",
                                                           weakSelf.requestContext.meId]];
            }
                                                       timestampProvider:self.requestContext.timestampProvider
                                                            uuidProvider:self.requestContext.uuidProvider];
        [_restClient executeTaskWithRequestModel:requestModel
                                    successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                        weakSelf.lastNotificationStatus.badgeCount = 0;
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
                completionBlock([NSError errorWithCode:42 localizedDescription:@"MeId is not available."]);
            }
        });
    }
}

- (void)trackNotificationOpenWithNotification:(EMSNotification *)inboxNotification {
    [self trackMessageOpenWith:inboxNotification
               completionBlock:nil];
}

- (void)trackMessageOpenWith:(EMSNotification *)inboxMessage
             completionBlock:(EMSCompletionBlock)completionBlock {
    NSParameterAssert(inboxMessage);
    EMSRequestModel *requestModel = [MERequestFactory createTrackMessageOpenRequestWithNotification:inboxMessage
                                                                                     requestContext:self.requestContext];
    if (!inboxMessage.id) {
        completionBlock([NSError errorWithCode:1
                          localizedDescription:@"Missing messageId"]);
    } else if (!inboxMessage.sid) {
        completionBlock([NSError errorWithCode:1
                          localizedDescription:@"Missing sid"]);
    } else {
        [self.requestManager submitRequestModel:requestModel withCompletionBlock:completionBlock];
    }
}

- (void)resetBadgeCount {
    [self resetBadgeCountWithCompletionBlock:nil];
}

- (void)purgeNotificationCache {
    if (!self.purgeTimestamp || [[self.timestampProvider provideTimestamp] timeIntervalSinceDate:self.purgeTimestamp] >= 60) {
        self.lastNotificationStatus = nil;
        self.purgeTimestamp = [self.timestampProvider provideTimestamp];
    }
}

#pragma mark - Private methods

- (NSDictionary<NSString *, NSString *> *)createNotificationsFetchingHeaders {
    NSDictionary *defaultHeaders = [MEDefaultHeaders additionalHeadersWithConfig:self.config];
    NSMutableDictionary *mutableFetchingHeaders = [NSMutableDictionary dictionaryWithDictionary:defaultHeaders];
    mutableFetchingHeaders[@"x-ems-me-application-code"] = self.config.applicationCode;
    mutableFetchingHeaders[@"Authorization"] = [EMSAuthentication createBasicAuthWithUsername:self.config.applicationCode
                                                                                     password:self.config.applicationPassword];
    return [NSDictionary dictionaryWithDictionary:mutableFetchingHeaders];
}

@end