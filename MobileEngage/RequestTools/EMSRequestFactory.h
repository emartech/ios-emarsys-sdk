//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class EMSRequestModel;
@class MERequestContext;
@class EMSDeviceInfo;

typedef enum {
    EventTypeInternal,
    EventTypeCustom
} EventType;

NS_ASSUME_NONNULL_BEGIN

@interface EMSRequestFactory : NSObject

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext;

- (EMSRequestModel *)createDeviceInfoRequestModel;

- (EMSRequestModel *)createPushTokenRequestModelWithPushToken:(NSString *)pushToken;

- (EMSRequestModel *)createContactRequestModel;

- (EMSRequestModel *)createEventRequestModelWithEventName:(NSString *)eventName
                                          eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes
                                                eventType:(EventType)eventType;
@end

NS_ASSUME_NONNULL_END