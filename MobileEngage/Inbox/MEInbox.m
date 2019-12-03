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
#import "EMSRequestManager.h"
#import "EMSNotificationCache.h"
#import "EMSRequestFactory.h"
#import "EMSEndpoint.h"

@interface MEInbox ()

@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSNotificationCache *notificationCache;
@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSEndpoint *endpoint;

@end

@implementation MEInbox

#pragma mark - Init

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext
                     notificationCache:(EMSNotificationCache *)notificationCache
                        requestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                              endpoint:(EMSEndpoint *)endpoint {
    NSParameterAssert(requestContext);
    NSParameterAssert(notificationCache);
    NSParameterAssert(requestManager);
    NSParameterAssert(requestFactory);
    NSParameterAssert(endpoint);
    if (self = [super init]) {
        _requestContext = requestContext;
        _notificationCache = notificationCache;
        _requestManager = requestManager;
        _requestFactory = requestFactory;
        _endpoint = endpoint;
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
                [[[builder setMethod:HTTPMethodGET] setHeaders:headers] setUrl:[NSString stringWithFormat:@"%@notifications",
                                                                                                          [self.endpoint inboxUrl]]];
            }
                                                  timestampProvider:self.requestContext.timestampProvider
                                                       uuidProvider:self.requestContext.uuidProvider];
        [self.requestManager submitRequestModelNow:request
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
                [builder setUrl:[NSString stringWithFormat:@"%@reset-badge-count", [self.endpoint inboxUrl]]];
                [builder setMethod:HTTPMethodPOST];
                [builder setHeaders:[self createNotificationsFetchingHeaders]];
            }
                                                timestampProvider:self.requestContext.timestampProvider
                                                     uuidProvider:self.requestContext.uuidProvider];
        [self.requestManager submitRequestModelNow:model
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

- (void)trackNotificationOpenWithNotification:(EMSNotification *)notification {
    [self trackNotificationOpenWithNotification:notification
                                completionBlock:nil];
}

- (void)trackNotificationOpenWithNotification:(EMSNotification *)notification
                              completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSParameterAssert(notification);
    EMSRequestModel *requestModel = [self.requestFactory createMessageOpenWithNotification:notification];

    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:completionBlock];;
}

#pragma mark - Private methods

- (NSDictionary<NSString *, NSString *> *)createNotificationsFetchingHeaders {
    NSDictionary *defaultHeaders = [MEDefaultHeaders additionalHeaders];
    NSMutableDictionary *mutableFetchingHeaders = [NSMutableDictionary dictionaryWithDictionary:defaultHeaders];
    mutableFetchingHeaders[@"x-ems-me-hardware-id"] = self.requestContext.deviceInfo.hardwareId;
    mutableFetchingHeaders[@"x-ems-me-application-code"] = self.requestContext.applicationCode;
    mutableFetchingHeaders[@"x-ems-me-contact-field-id"] = [NSString stringWithFormat:@"%@",
                                                                                      self.requestContext.contactFieldId];
    mutableFetchingHeaders[@"x-ems-me-contact-field-value"] = self.requestContext.contactFieldValue;
    mutableFetchingHeaders[@"Authorization"] = [EMSAuthentication createBasicAuthWithUsername:self.requestContext.applicationCode];
    return [NSDictionary dictionaryWithDictionary:mutableFetchingHeaders];
}

- (BOOL)hasLoginParameters {
    return self.requestContext.contactFieldId && self.requestContext.contactFieldValue;
}

@end
