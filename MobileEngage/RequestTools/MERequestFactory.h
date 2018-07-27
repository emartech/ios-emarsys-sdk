//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSSchemaContract.h"

@class MERequestContext;
@class MENotification;
@class EMSRequestModel;

@interface MERequestFactory : NSObject

+ (EMSRequestModel *)createLoginOrLastMobileActivityRequestWithPushToken:(NSData *)pushToken
                                                          requestContext:(MERequestContext *)requestContext;

+ (EMSRequestModel *)createAppLogoutRequestWithRequestContext:(MERequestContext *)requestContext;

+ (EMSRequestModel *)createTrackMessageOpenRequestWithNotification:(MENotification *)inboxMessage
                                                    requestContext:(MERequestContext *)requestContext;

+ (EMSRequestModel *)createTrackMessageOpenRequestWithMessageId:(NSString *)messageId
                                                 requestContext:(MERequestContext *)requestContext;

+ (EMSRequestModel *)createTrackCustomEventRequestWithEventName:(NSString *)eventName
                                                eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes
                                                 requestContext:(MERequestContext *)requestContext;

+ (EMSRequestModel *)createCustomEventModelWithEventName:(NSString *)eventName
                                         eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes
                                                    type:(NSString *)type
                                          requestContext:(MERequestContext *)requestContext;

+ (EMSRequestModel *)createTrackDeepLinkRequestWithTrackingId:(NSString *)trackingId
                                               requestContext:(MERequestContext *)requestContext;

@end