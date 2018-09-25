//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSAuthentication.h"
#import "MEInboxV2.h"
#import "MEInboxParser.h"
#import "EMSResponseModel.h"
#import "MEDefaultHeaders.h"
#import "MobileEngage+Private.h"
#import "NSError+EMSCore.h"
#import "MERequestFactory.h"

@interface MEInboxV2 ()

@property(nonatomic, strong) EMSRESTClient *restClient;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSConfig *config;
@property(nonatomic, strong) NSMutableArray *notifications;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) NSMutableArray *resultBlocks;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, assign) BOOL fetchRequestInProgress;

@end

@implementation MEInboxV2

- (instancetype)initWithConfig:(EMSConfig *)config
                requestContext:(MERequestContext *)requestContext
                    restClient:(EMSRESTClient *)restClient
                 notifications:(NSMutableArray *)notifications
             timestampProvider:(EMSTimestampProvider *)timestampProvider
                requestManager:(EMSRequestManager *)requestManager {
    if (self = [super init]) {
        NSParameterAssert(timestampProvider);
        NSParameterAssert(notifications);
        NSParameterAssert(config);
        NSParameterAssert(restClient);
        NSParameterAssert(requestContext);
        NSParameterAssert(requestManager);
        _restClient = restClient;
        _config = config;
        _notifications = notifications;
        _requestContext = requestContext;
        _timestampProvider = timestampProvider;
        _resultBlocks = [NSMutableArray new];
        _requestManager = requestManager;
    }
    return self;
}


- (void)fetchNotificationsWithResultBlock:(EMSFetchNotificationResultBlock)resultBlock {
    NSParameterAssert(resultBlock);
    if (self.lastNotificationStatus && [[self.timestampProvider provideTimestamp] timeIntervalSinceDate:self.responseTimestamp] < 60) {
        resultBlock([self mergedStatusWithStatus:self.lastNotificationStatus], nil);
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
                                            EMSNotificationInboxStatus *inboxStatus = [weakSelf mergedStatusWithStatus:status];
                                            resultBlock(inboxStatus, nil);

                                            for (MEInboxResultBlock successBlock in weakSelf.resultBlocks) {
                                                successBlock(inboxStatus);
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
        [self.requestManager submitRequestModel:requestModel];
    }
}


- (NSString *)trackMessageOpenWithInboxMessage:(EMSNotification *)inboxMessage {
    return [MobileEngage trackMessageOpenWithInboxMessage:inboxMessage];
}

- (void)resetBadgeCount {
    [self resetBadgeCountWithCompletionBlock:nil];
}

- (void)addNotification:(EMSNotification *)notification {
    [self.notifications insertObject:notification
                             atIndex:0];
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

- (EMSNotificationInboxStatus *)mergedStatusWithStatus:(EMSNotificationInboxStatus *)status {
    [self invalidateCachedNotifications:status];

    NSMutableArray *statusNotifications = [NSMutableArray new];
    [statusNotifications addObjectsFromArray:self.notifications];
    [statusNotifications addObjectsFromArray:status.notifications];
    status.notifications = statusNotifications;
    return status;
}

- (void)invalidateCachedNotifications:(EMSNotificationInboxStatus *)status {
    for (int i = (int) [self.notifications count] - 1; i >= 0; --i) {
        EMSNotification *notification = self.notifications[(NSUInteger) i];
        for (EMSNotification *currentNotification in status.notifications) {
            if ([currentNotification.id isEqual:notification.id]) {
                [self.notifications removeObjectAtIndex:(NSUInteger) i];
                break;
            }
        }
    }
}

@end