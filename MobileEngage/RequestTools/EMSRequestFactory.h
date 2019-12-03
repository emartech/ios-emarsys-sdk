//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class EMSRequestModel;
@class MERequestContext;
@class EMSDeviceInfo;
@class EMSNotification;
@class EMSEndpoint;

typedef enum {
    EventTypeInternal,
    EventTypeCustom
} EventType;

NS_ASSUME_NONNULL_BEGIN

@interface EMSRequestFactory : NSObject

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext
                              endpoint:(EMSEndpoint *)endpoint;

- (EMSRequestModel *)createDeviceInfoRequestModel;

- (EMSRequestModel *)createPushTokenRequestModelWithPushToken:(NSString *)pushToken;

- (EMSRequestModel *)createClearPushTokenRequestModel;

- (EMSRequestModel *)createContactRequestModel;

- (EMSRequestModel *)createEventRequestModelWithEventName:(NSString *)eventName
                                          eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes
                                                eventType:(EventType)eventType;

- (EMSRequestModel *)createRefreshTokenRequestModel;

- (EMSRequestModel *)createDeepLinkRequestModelWithTrackingId:(NSString *)trackingId;

- (EMSRequestModel *)createMessageOpenWithNotification:(EMSNotification *)notification;

@end

NS_ASSUME_NONNULL_END