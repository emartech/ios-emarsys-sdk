//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MERequestFactory_old.h"
#import "MERequestContext.h"
#import "EmarsysSDKVersion.h"
#import "NSData+MobileEngine.h"
#import "EMSNotification.h"
#import "MEExperimental.h"
#import "EMSRequestModel.h"
#import "EMSDeviceInfo.h"
#import "NSDate+EMSCore.h"
#import "EMSAuthentication.h"

@implementation MERequestFactory_old

+ (EMSRequestModel *)createLoginOrLastMobileActivityRequestWithPushToken:(NSData *)pushToken
                                                          requestContext:(MERequestContext *)requestContext {
    EMSRequestModel *requestModel = [self createAppLoginRequestWithPushToken:pushToken
                                                              requestContext:requestContext];
    if ([self shouldSendLastMobileActivityWithRequestContext:requestContext
                                      currentAppLoginPayload:requestModel.payload]) {
        requestModel = [MERequestFactory_old createCustomEventModelWithEventName:@"last_mobile_activity"
                                                                 eventAttributes:nil
                                                                            type:@"internal"
                                                                  requestContext:requestContext];
    } else {
        requestContext.lastAppLoginPayload = requestModel.payload;
    }
    return requestModel;
}

+ (BOOL)shouldSendLastMobileActivityWithRequestContext:(MERequestContext *)requestContext
                                currentAppLoginPayload:(NSDictionary *)currentAppLoginPayload {
    return ([requestContext.lastAppLoginPayload isEqual:currentAppLoginPayload] && requestContext.meId);
}

+ (EMSRequestModel *)createAppLoginRequestWithPushToken:(NSData *)pushToken
                                         requestContext:(MERequestContext *)requestContext {
    return [self requestModelWithUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login"
                              method:HTTPMethodPOST
              additionalPayloadBlock:^(NSMutableDictionary *payload) {
                  payload[@"platform"] = @"ios";
                  payload[@"language"] = requestContext.deviceInfo.languageCode;
                  payload[@"timezone"] = requestContext.deviceInfo.timeZone;
                  payload[@"device_model"] = requestContext.deviceInfo.deviceModel;
                  payload[@"os_version"] = requestContext.deviceInfo.osVersion;
                  payload[@"ems_sdk"] = EMARSYS_SDK_VERSION;

                  NSString *appVersion = requestContext.deviceInfo.applicationVersion;
                  if (appVersion) {
                      payload[@"application_version"] = appVersion;
                  }
                  if (pushToken) {
                      payload[@"push_token"] = [pushToken deviceTokenString];
                  } else {
                      payload[@"push_token"] = @NO;
                  }
              }
                      requestContext:requestContext];
}

+ (EMSRequestModel *)createAppLogoutRequestWithRequestContext:(MERequestContext *)requestContext {
    EMSRequestModel *requestModel = [MERequestFactory_old requestModelWithUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/logout"
                                                                       method:HTTPMethodPOST
                                                       additionalPayloadBlock:nil
                                                               requestContext:requestContext];
    return requestModel;
}

+ (EMSRequestModel *)createTrackMessageOpenRequestWithNotification:(EMSNotification *)inboxMessage
                                                    requestContext:(MERequestContext *)requestContext {
    EMSRequestModel *requestModel;
    if ([MEExperimental isFeatureEnabled:USER_CENTRIC_INBOX]) {
        NSMutableDictionary *attributes = [NSMutableDictionary new];

        if (inboxMessage.id) {
            attributes[@"message_id"] = inboxMessage.id;
        }

        if (inboxMessage.sid) {
            attributes[@"sid"] = inboxMessage.sid;
        }

        requestModel = [MERequestFactory_old createCustomEventModelWithEventName:@"inbox:open"
                                                                 eventAttributes:attributes
                                                                            type:@"internal"
                                                                  requestContext:requestContext];
    } else {
        requestModel = [MERequestFactory_old requestModelWithUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open"
                                                          method:HTTPMethodPOST
                                          additionalPayloadBlock:^(NSMutableDictionary *payload) {
                                          payload[@"sid"] = inboxMessage.sid;
                                          payload[@"source"] = @"inbox";
                                      }
                                                  requestContext:requestContext];
    }
    return requestModel;
}

+ (EMSRequestModel *)createTrackMessageOpenRequestWithMessageId:(NSString *)messageId
                                                 requestContext:(MERequestContext *)requestContext {
    EMSRequestModel *requestModel;
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if (messageId) {
        attributes[@"sid"] = messageId;
    }

    requestModel = [MERequestFactory_old createCustomEventModelWithEventName:@"inbox:open"
                                                             eventAttributes:attributes
                                                                        type:@"internal"
                                                              requestContext:requestContext];
    return requestModel;
}

+ (EMSRequestModel *)createTrackCustomEventRequestWithEventName:(NSString *)eventName
                                                eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes
                                                 requestContext:(MERequestContext *)requestContext {
    EMSRequestModel *requestModel = [MERequestFactory_old createCustomEventModelWithEventName:eventName
                                                                              eventAttributes:eventAttributes
                                                                                         type:@"custom"
                                                                               requestContext:requestContext];
    return requestModel;
}

+ (EMSRequestModel *)createCustomEventModelWithEventName:(NSString *)eventName
                                         eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes
                                                    type:(NSString *)type
                                          requestContext:(MERequestContext *)requestContext {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setMethod:HTTPMethodPOST];
            [builder setUrl:[NSString stringWithFormat:@"https://mobile-events.eservice.emarsys.net/v3/devices/%@/events",
                                                       requestContext.meId]];
            NSMutableDictionary *payload = [NSMutableDictionary new];
            payload[@"clicks"] = @[];
            payload[@"viewed_messages"] = @[];
            payload[@"hardware_id"] = requestContext.deviceInfo.hardwareId;

            NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
                @"type": type,
                @"name": eventName,
                @"timestamp": [[requestContext.timestampProvider provideTimestamp] stringValueInUTC]}];

            if (eventAttributes) {
                event[@"attributes"] = eventAttributes;
            }

            payload[@"events"] = @[event];
            NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
            if (requestContext.meId) {
                mutableHeaders[@"X-ME-ID"] = requestContext.meId;
            }
            if (requestContext.meIdSignature) {
                mutableHeaders[@"X-ME-ID-SIGNATURE"] = requestContext.meIdSignature;
            }
            mutableHeaders[@"X-ME-APPLICATIONCODE"] = requestContext.config.applicationCode;
            [builder setHeaders:mutableHeaders];

            [builder setPayload:payload];
        }
                          timestampProvider:requestContext.timestampProvider
                               uuidProvider:requestContext.uuidProvider];
}

+ (EMSRequestModel *)createTrackDeepLinkRequestWithTrackingId:(NSString *)trackingId
                                               requestContext:(MERequestContext *)requestContext {
    NSString *userAgent = [NSString stringWithFormat:@"Mobile Engage SDK %@ %@ %@", EMARSYS_SDK_VERSION,
                                                     requestContext.deviceInfo.deviceType,
                                                     requestContext.deviceInfo.osVersion];
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setMethod:HTTPMethodPOST];
            [builder setUrl:@"https://deep-link.eservice.emarsys.net/api/clicks"];
            [builder setHeaders:@{@"User-Agent": userAgent}];
            [builder setPayload:@{@"ems_dl": trackingId}];
        }
                          timestampProvider:requestContext.timestampProvider
                               uuidProvider:requestContext.uuidProvider];
}

+ (EMSRequestModel *)requestModelWithUrl:(NSString *)url
                                  method:(HTTPMethod)method
                  additionalPayloadBlock:(void (^)(NSMutableDictionary *payload))payloadBlock
                          requestContext:(MERequestContext *)requestContext {
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:url];
            [builder setMethod:method];
            NSMutableDictionary *payload = [@{
                @"application_id": requestContext.config.applicationCode,
                @"hardware_id": requestContext.deviceInfo.hardwareId
            } mutableCopy];

            if (requestContext.appLoginParameters.contactFieldId && requestContext.appLoginParameters.contactFieldValue) {
                payload[@"contact_field_id"] = requestContext.appLoginParameters.contactFieldId;
                payload[@"contact_field_value"] = requestContext.appLoginParameters.contactFieldValue;
            }

            if (payloadBlock) {
                payloadBlock(payload);
            }

            [builder setPayload:payload];
            [builder setHeaders:@{@"Authorization": [EMSAuthentication createBasicAuthWithUsername:requestContext.config.applicationCode
                                                                                          password:requestContext.config.applicationPassword]}];
        }
                                                   timestampProvider:requestContext.timestampProvider
                                                        uuidProvider:requestContext.uuidProvider];
    return requestModel;
}

@end
