//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSAuthentication.h"
#import "MEInboxV2.h"
#import "EMSSchemaContract.h"
#import "MEInboxParser.h"
#import "EMSResponseModel.h"
#import "MEDefaultHeaders.h"
#import "MobileEngage+Private.h"
#import "NSError+EMSCore.h"
#import "MENotificationInboxStatus.h"

@interface MEInboxV2 ()

@property(nonatomic, strong) EMSRESTClient *restClient;
@property(nonatomic, strong) EMSConfig *config;
@property(nonatomic, strong) NSMutableArray *notifications;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) NSMutableArray *fetchRequestSuccessBlocks;
@property(nonatomic, strong) NSMutableArray *fetchRequestErrorBlocks;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, assign) BOOL fetchRequestInProgress;

@end

@implementation MEInboxV2

- (instancetype)initWithConfig:(EMSConfig *)config
                requestContext:(MERequestContext *)requestContext
                    restClient:(EMSRESTClient *)restClient
                 notifications:(NSMutableArray *)notifications
             timestampProvider:(EMSTimestampProvider *)timestampProvider {
    self = [super init];
    if (self) {
        NSParameterAssert(timestampProvider);
        NSParameterAssert(notifications);
        NSParameterAssert(config);
        NSParameterAssert(restClient);
        NSParameterAssert(requestContext);
        _restClient = restClient;
        _config = config;
        _notifications = notifications;
        _requestContext = requestContext;
        _timestampProvider = timestampProvider;
        _fetchRequestSuccessBlocks = [NSMutableArray new];
        _fetchRequestErrorBlocks = [NSMutableArray new];
    }
    return self;
}


- (void)fetchNotificationsWithResultBlock:(MEInboxResultBlock)resultBlock
                               errorBlock:(MEInboxResultErrorBlock)errorBlock {
    NSParameterAssert(resultBlock);

    if (self.lastNotificationStatus && [[self.timestampProvider provideTimestamp] timeIntervalSinceDate:self.responseTimestamp] < 60) {
        resultBlock([self mergedStatusWithStatus:self.lastNotificationStatus]);
        return;
    } else if (self.fetchRequestInProgress) {
        [self.fetchRequestSuccessBlocks addObject:[resultBlock copy]];
        [self.fetchRequestErrorBlocks addObject:[errorBlock copy]];
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
                                        MENotificationInboxStatus *status = [[MEInboxParser new] parseNotificationInboxStatus:payload];
                                        weakSelf.lastNotificationStatus = status;
                                        weakSelf.responseTimestamp = [weakSelf.timestampProvider provideTimestamp];
                                        weakSelf.fetchRequestInProgress = NO;

                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            MENotificationInboxStatus *inboxStatus = [weakSelf mergedStatusWithStatus:status];
                                            resultBlock(inboxStatus);

                                            for (MEInboxResultBlock successBlock in weakSelf.fetchRequestSuccessBlocks) {
                                                successBlock(inboxStatus);
                                            }
                                            [weakSelf.fetchRequestSuccessBlocks removeAllObjects];
                                        });
                                    }
                                      errorBlock:^(NSString *requestId, NSError *error) {
                                          [weakSelf respondWithError:errorBlock error:error];
                                          weakSelf.fetchRequestInProgress = NO;

                                          for (MEInboxResultErrorBlock errorsBlock in weakSelf.fetchRequestErrorBlocks) {
                                              [weakSelf respondWithError:errorsBlock error:error];
                                          }
                                          [weakSelf.fetchRequestErrorBlocks removeAllObjects];
                                      }];
    } else {
        [self handleNoMeIdWithErrorBlock:errorBlock];
    }
}

- (void)resetBadgeCountWithSuccessBlock:(MEInboxSuccessBlock)successBlock
                             errorBlock:(MEInboxResultErrorBlock)errorBlock {
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
                                            if (successBlock) {
                                                successBlock();
                                            }
                                        });
                                    }
                                      errorBlock:^(NSString *requestId, NSError *error) {
                                          [weakSelf respondWithError:errorBlock error:error];
                                      }];
    } else {
        [self handleNoMeIdWithErrorBlock:errorBlock];
    }
}

- (void)resetBadgeCount {
    [self resetBadgeCountWithSuccessBlock:nil errorBlock:nil];
}

- (void)addNotification:(MENotification *)notification {
    [self.notifications insertObject:notification
                             atIndex:0];
}

- (NSString *)trackMessageOpenWithInboxMessage:(MENotification *)inboxMessage {
    return [MobileEngage trackMessageOpenWithInboxMessage:inboxMessage];
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

- (MENotificationInboxStatus *)mergedStatusWithStatus:(MENotificationInboxStatus *)status {
    [self invalidateCachedNotifications:status];

    NSMutableArray *statusNotifications = [NSMutableArray new];
    [statusNotifications addObjectsFromArray:self.notifications];
    [statusNotifications addObjectsFromArray:status.notifications];
    status.notifications = statusNotifications;
    return status;
}

- (void)invalidateCachedNotifications:(MENotificationInboxStatus *)status {
    for (int i = (int) [self.notifications count] - 1; i >= 0; --i) {
        MENotification *notification = self.notifications[(NSUInteger) i];
        for (MENotification *currentNotification in status.notifications) {
            if ([currentNotification.id isEqual:notification.id]) {
                [self.notifications removeObjectAtIndex:(NSUInteger) i];
                break;
            }
        }
    }
}

- (void)respondWithError:(MEInboxResultErrorBlock)errorBlock error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errorBlock) {
            errorBlock(error);
        }
    });
}

- (void)handleNoMeIdWithErrorBlock:(MEInboxResultErrorBlock)errorBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errorBlock) {
            errorBlock([NSError errorWithCode:42 localizedDescription:@"MeId is not available."]);
        }
    });
}

@end