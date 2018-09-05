//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSError+EMSCore.h"
#import "MEInbox.h"
#import "MEDefaultHeaders.h"
#import "EMSConfig.h"
#import "MEInboxParser.h"
#import "MERequestContext.h"
#import "MobileEngage+Private.h"
#import "EMSRequestModelBuilder.h"
#import "EMSResponseModel.h"
#import "EMSDeviceInfo.h"
#import "EMSRESTClient.h"
#import "EMSAuthentication.h"

@interface MEInbox ()

@property(nonatomic, strong) EMSRESTClient *restClient;
@property(nonatomic, strong) EMSConfig *config;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) NSMutableArray *notifications;

@end

@implementation MEInbox

#pragma mark - Init

- (instancetype)initWithConfig:(EMSConfig *)config
                requestContext:(MERequestContext *)requestContext {
    EMSRESTClient *restClient = [EMSRESTClient clientWithSession:[NSURLSession sharedSession]];
    return [self initWithRestClient:restClient
                             config:config
                     requestContext:requestContext];
}

- (instancetype)initWithRestClient:(EMSRESTClient *)restClient
                            config:(EMSConfig *)config
                    requestContext:(MERequestContext *)requestContext {
    self = [super init];
    if (self) {
        _restClient = restClient;
        _config = config;
        _notifications = [NSMutableArray new];
        _requestContext = requestContext;
    }
    return self;
}

#pragma mark - Public methods

- (void)fetchNotificationsWithResultBlock:(MEInboxResultBlock)resultBlock
                               errorBlock:(MEInboxResultErrorBlock)errorBlock {
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
                                        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:response.body options:0 error:nil];
                                        MENotificationInboxStatus *status = [[MEInboxParser new] parseNotificationInboxStatus:payload];
                                        MENotificationInboxStatus *mergedStatus = [weakSelf mergedStatusWithStatus:status];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            resultBlock(mergedStatus);
                                        });
                                    }
                                      errorBlock:^(NSString *requestId, NSError *error) {
                                          [weakSelf respondWithError:errorBlock error:error];
                                      }];
    } else {
        [self handleNoLoginParameters:errorBlock];
    }
}

- (void)resetBadgeCount {
    [self resetBadgeCountWithSuccessBlock:nil errorBlock:nil];
}

- (void)resetBadgeCountWithSuccessBlock:(MEInboxSuccessBlock)successBlock
                             errorBlock:(MEInboxResultErrorBlock)errorBlock {
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
                                            if (successBlock) {
                                                successBlock();
                                            }
                                        });
                                    }
                                      errorBlock:^(NSString *requestId, NSError *error) {
                                          [self respondWithError:errorBlock error:error];
                                      }];
    } else {
        [self handleNoLoginParameters:errorBlock];
    }
}

- (void)addNotification:(MENotification *)notification {
    [self.notifications insertObject:notification
                             atIndex:0];
}

- (NSString *)trackMessageOpenWithInboxMessage:(MENotification *)inboxMessage {
    return [MobileEngage trackMessageOpenWithInboxMessage:inboxMessage];
}

- (void)purgeNotificationCache {
}


#pragma mark - Private methods

- (NSDictionary<NSString *, NSString *> *)createNotificationsFetchingHeaders {
    NSDictionary *defaultHeaders = [MEDefaultHeaders additionalHeadersWithConfig:self.config];
    NSMutableDictionary *mutableFetchingHeaders = [NSMutableDictionary dictionaryWithDictionary:defaultHeaders];
    mutableFetchingHeaders[@"x-ems-me-hardware-id"] = [EMSDeviceInfo hardwareId];
    mutableFetchingHeaders[@"x-ems-me-application-code"] = self.config.applicationCode;
    mutableFetchingHeaders[@"x-ems-me-contact-field-id"] = [NSString stringWithFormat:@"%@", self.requestContext.appLoginParameters.contactFieldId];
    mutableFetchingHeaders[@"x-ems-me-contact-field-value"] = self.requestContext.appLoginParameters.contactFieldValue;
    mutableFetchingHeaders[@"Authorization"] = [EMSAuthentication createBasicAuthWithUsername:self.config.applicationCode
                                                                                     password:self.config.applicationPassword];
    return [NSDictionary dictionaryWithDictionary:mutableFetchingHeaders];
}

- (MENotificationInboxStatus *)mergedStatusWithStatus:(MENotificationInboxStatus *)status {
    [self invalidateCachedNotifications:status];

    NSMutableArray *notifications = [NSMutableArray new];
    [notifications addObjectsFromArray:self.notifications];
    [notifications addObjectsFromArray:status.notifications];

    MENotificationInboxStatus *result = [MENotificationInboxStatus new];
    result.badgeCount = status.badgeCount;
    result.notifications = [NSArray arrayWithArray:notifications];
    return result;
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

- (BOOL)hasLoginParameters {
    return self.requestContext.appLoginParameters && self.requestContext.appLoginParameters.contactFieldId && self.requestContext.appLoginParameters.contactFieldValue;
}

- (void)respondWithError:(MEInboxResultErrorBlock)errorBlock error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errorBlock) {
            errorBlock(error);
        }
    });
}

- (void)handleNoLoginParameters:(MEInboxResultErrorBlock)errorBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errorBlock) {
            errorBlock([NSError errorWithCode:42
                         localizedDescription:@"Login parameters are not available."]);
        }
    });
}

@end
