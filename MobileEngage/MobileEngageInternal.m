//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MobileEngageInternal.h"
#import "NSDictionary+MobileEngage.h"
#import "NSError+EMSCore.h"
#import "MERequestContext.h"
#import "MERequestFactory_old.h"
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
    [self.requestManager submitRequestModel:[MERequestFactory_old createCustomEventModelWithEventName:@"inapp:viewed"
                                                                                      eventAttributes:@{@"message_id": campaignId}
                                                                                                 type:@"internal"
                                                                                       requestContext:self.requestContext]
                        withCompletionBlock:nil];
}

- (void)trackInAppClick:(NSString *)campaignId buttonId:(NSString *)buttonId {
    [self.requestManager submitRequestModel:[MERequestFactory_old createCustomEventModelWithEventName:@"inapp:click"
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

//    if (self.requestContext.appLoginParameters != nil) {
//        [self setContactWithContactFieldValue:self.requestContext.appLoginParameters.contactFieldValue];
//    }
}

- (void)setPushToken:(NSData *)pushToken
     completionBlock:(EMSCompletionBlock)completionBlock {
    [self setPushToken:pushToken];
}


- (void)setAnonymousContactWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    [self setContactWithContactFieldValue:nil
                          completionBlock:completionBlock];
}

- (void)setAnonymousContact {
    return [self setContactWithContactFieldValue:nil];
}

- (void)setContactWithContactFieldValue:(NSString *)contactFieldValue {
    [self setContactWithContactFieldValue:contactFieldValue
                          completionBlock:nil];
}

- (void)setContactWithContactFieldValue:(NSString *)contactFieldValue
                        completionBlock:(EMSCompletionBlock)completionBlock {
    self.requestContext.contactFieldValue = contactFieldValue;

    EMSRequestModel *requestModel = [MERequestFactory_old createLoginOrLastMobileActivityRequestWithPushToken:self.pushToken
                                                                                               requestContext:self.requestContext];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:completionBlock];
}

- (void)clearContact {
    [self clearContactWithCompletionBlock:nil];
}

- (void)clearContactWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    EMSRequestModel *requestModel = [MERequestFactory_old createAppLogoutRequestWithRequestContext:self.requestContext];
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
        [self.notificationCache cache:[[EMSNotification alloc] initWithUserInfo:userInfo timestampProvider:nil]];
    }
    NSString *messageId = [userInfo messageId];
    if (messageId) {
        EMSRequestModel *requestModel = [MERequestFactory_old createCustomEventModelWithEventName:@"push:click"
                                                                                  eventAttributes:@{
                                                                                      @"origin": @"main",
                                                                                      @"sid": messageId
                                                                                  }
                                                                                             type:@"internal"
                                                                                   requestContext:self.requestContext];
        [self.requestManager submitRequestModel:requestModel
                            withCompletionBlock:completionBlock];
    } else {
        completionBlock([NSError errorWithCode:1
                          localizedDescription:@"Missing messageId"]);
    }
}


- (void)trackCustomEventWithName:(nonnull NSString *)eventName
                 eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes {
    [self trackCustomEventWithName:eventName eventAttributes:eventAttributes completionBlock:nil];
}

- (void)trackCustomEventWithName:(nonnull NSString *)eventName
                 eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes
                 completionBlock:(EMSCompletionBlock)completionBlock {
    NSParameterAssert(eventName);

    EMSRequestModel *requestModel = [MERequestFactory_old createTrackCustomEventRequestWithEventName:eventName
                                                                                     eventAttributes:eventAttributes
                                                                                      requestContext:self.requestContext];
    [self.requestManager submitRequestModel:requestModel withCompletionBlock:completionBlock];
}

- (NSString *)trackInternalCustomEvent:(NSString *)eventName
                       eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes
                       completionBlock:(EMSCompletionBlock)completionBlock {
    NSParameterAssert(eventName);

    EMSRequestModel *requestModel = [MERequestFactory_old createCustomEventModelWithEventName:eventName
                                                                              eventAttributes:eventAttributes
                                                                                         type:@"internal"
                                                                               requestContext:self.requestContext];
    [self.requestManager submitRequestModel:requestModel withCompletionBlock:completionBlock];
    return requestModel.requestId;
}

@end
