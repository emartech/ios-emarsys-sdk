//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MobileEngageInternal.h"
#import "NSDictionary+MobileEngage.h"
#import "NSError+EMSCore.h"
#import "MobileEngage.h"
#import "MERequestContext.h"
#import "MERequestFactory.h"
#import "EMSNotificationCache.h"

@interface MobileEngageInternal ()

@property(nonatomic, strong) EMSNotificationCache *notificationCache;

@end

@implementation MobileEngageInternal

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestContext:(MERequestContext *)requestContext
                     notificationCache:(EMSNotificationCache *)notificationCache {
    if (self = [super init]) {
        _notificationCache = notificationCache;
        _requestContext = requestContext;
        _requestManager = requestManager;
    }
    return self;
}

- (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(nullable MESourceHandler)sourceHandler
      withCompletionBlock:(EMSCompletionBlock)completionBlock {
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
                                                                                                requestContext:self.requestContext]
                                withCompletionBlock:completionBlock];
        }
    }
    return result;
}

- (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(nullable MESourceHandler)sourceHandler {
    return [self trackDeepLinkWith:userActivity sourceHandler:sourceHandler withCompletionBlock:nil];
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
                                                                                   requestContext:self.requestContext]
                        withCompletionBlock:nil];
}

- (void)trackInAppClick:(NSString *)campaignId buttonId:(NSString *)buttonId {
    [self.requestManager submitRequestModel:[MERequestFactory createCustomEventModelWithEventName:@"inapp:click"
                                                                                  eventAttributes:@{
                                                                                      @"message_id": campaignId,
                                                                                      @"button_id": buttonId
                                                                                  }
                                                                                             type:@"internal"
                                                                                   requestContext:self.requestContext]
                        withCompletionBlock:nil];
}

- (void)setPushToken:(NSData *)pushToken {
    _pushToken = pushToken;

    if (self.requestContext.appLoginParameters != nil) {
        [self appLoginWithContactFieldValue:self.requestContext.appLoginParameters.contactFieldValue];
    }
}

- (void)appLogin {
    return [self appLoginWithContactFieldValue:nil];
}

- (void)appLoginWithContactFieldValue:(NSString *)contactFieldValue {
    [self appLoginWithContactFieldValue:contactFieldValue
                        completionBlock:nil];
}

- (void)appLoginWithContactFieldValue:(NSString *)contactFieldValue
                      completionBlock:(EMSCompletionBlock)completionBlock {
    self.requestContext.appLoginParameters = [MEAppLoginParameters parametersWithContactFieldId:self.requestContext.contactFieldId
                                                                              contactFieldValue:contactFieldValue];

    EMSRequestModel *requestModel = [MERequestFactory createLoginOrLastMobileActivityRequestWithPushToken:self.pushToken
                                                                                           requestContext:self.requestContext];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:completionBlock];
}

- (void)appLogout {
    [self appLogoutWithCompletionBlock:nil];
}

- (void)appLogoutWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    EMSRequestModel *requestModel = [MERequestFactory createAppLogoutRequestWithRequestContext:self.requestContext];
    [self.requestContext reset];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:completionBlock];
}

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo {
    [self trackMessageOpenWithUserInfo:userInfo
                       completionBlock:nil];
}

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo
                     completionBlock:(EMSCompletionBlock)completionBlock {
    NSNumber *inbox = userInfo[@"inbox"];
    if (inbox && [inbox boolValue]) {
        [self.notificationCache cache:[[EMSNotification alloc] initWithUserInfo:userInfo]];
    }
    NSString *messageId = [userInfo messageId];
    if (messageId) {
        EMSRequestModel *requestModel = [MERequestFactory createTrackMessageOpenRequestWithMessageId:messageId
                                                                                      requestContext:self.requestContext];
        [self.requestManager submitRequestModel:requestModel withCompletionBlock:completionBlock];
    } else {
        completionBlock([NSError errorWithCode:1
                          localizedDescription:@"Missing messageId"]);
    }
}


- (void)trackCustomEvent:(nonnull NSString *)eventName
         eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes {
    [self trackCustomEvent:eventName eventAttributes:eventAttributes completionBlock:nil];
}

- (void)trackCustomEvent:(nonnull NSString *)eventName
         eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes
         completionBlock:(EMSCompletionBlock)completionBlock {
    NSParameterAssert(eventName);

    EMSRequestModel *requestModel = [MERequestFactory createTrackCustomEventRequestWithEventName:eventName
                                                                                 eventAttributes:eventAttributes
                                                                                  requestContext:self.requestContext];
    [self.requestManager submitRequestModel:requestModel withCompletionBlock:completionBlock];
}

- (NSString *)trackInternalCustomEvent:(NSString *)eventName
                       eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes
                       completionBlock:(EMSCompletionBlock)completionBlock {
    NSParameterAssert(eventName);
    EMSRequestModel *requestModel = [MERequestFactory createCustomEventModelWithEventName:eventName
                                                                          eventAttributes:eventAttributes
                                                                                     type:@"internal"
                                                                           requestContext:self.requestContext];
    [self.requestManager submitRequestModel:requestModel withCompletionBlock:completionBlock];
    return requestModel.requestId;
}


@end
