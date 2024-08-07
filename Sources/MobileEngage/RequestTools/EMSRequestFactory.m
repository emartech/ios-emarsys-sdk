//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSRequestFactory.h"
#import "EMSRequestModel.h"
#import "MERequestContext.h"
#import "PRERequestContext.h"
#import "EMSEndpoint.h"
#import "EMSDeviceInfo+MEClientPayload.h"
#import "NSDate+EMSCore.h"
#import "EmarsysSDKVersion.h"
#import "EMSAuthentication.h"
#import "MEButtonClickRepository.h"
#import "EMSFilterByNothingSpecification.h"
#import "EMSSessionIdHolder.h"
#import "EMSStorage.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"
#import "EMSStorageProtocol.h"

@interface EMSRequestFactory ()

@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) PRERequestContext *predictRequestContext;
@property(nonatomic, strong) EMSDeviceInfo *deviceInfo;
@property(nonatomic, strong) EMSEndpoint *endpoint;
@property(nonatomic, strong) MEButtonClickRepository *buttonClickRepository;
@property(nonatomic, strong) EMSSessionIdHolder *sessionIdHolder;
@property(nonatomic, strong) id <EMSStorageProtocol> storage;

@end

#define kDeviceEventStateKey @"DEVICE_EVENT_STATE_KEY"

@implementation EMSRequestFactory

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext
                 predictRequestContext:(PRERequestContext *)predictRequestContext
                              endpoint:(EMSEndpoint *)endpoint
                 buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
                       sessionIdHolder:(EMSSessionIdHolder *)sessionIdHolder
                               storage:(id <EMSStorageProtocol>)storage {
    NSParameterAssert(requestContext);
    NSParameterAssert(predictRequestContext);
    NSParameterAssert(endpoint);
    NSParameterAssert(buttonClickRepository);
    NSParameterAssert(sessionIdHolder);
    NSParameterAssert(storage);
    if (self = [super init]) {
        _requestContext = requestContext;
        _predictRequestContext = predictRequestContext;
        _deviceInfo = requestContext.deviceInfo;
        _endpoint = endpoint;
        _buttonClickRepository = buttonClickRepository;
        _sessionIdHolder = sessionIdHolder;
        _storage = storage;
    }
    return self;
}

- (EMSRequestModel *_Nullable)createDeviceInfoRequestModel {
    __weak typeof(self) weakSelf = self;
    return [self requestModelWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:[weakSelf.endpoint clientUrlWithApplicationCode:weakSelf.requestContext.applicationCode]];
        [builder setMethod:HTTPMethodPOST];
        [builder setPayload:[weakSelf.deviceInfo clientPayload]];
    }];
}

- (EMSRequestModel *_Nullable)createPushTokenRequestModelWithPushToken:(NSString *)pushToken {
    __weak typeof(self) weakSelf = self;
    return [self requestModelWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:[weakSelf.endpoint pushTokenUrlWithApplicationCode:weakSelf.requestContext.applicationCode]];
                [builder setMethod:HTTPMethodPUT];
                [builder setPayload:@{@"pushToken": pushToken}];
            }];
}

- (EMSRequestModel *_Nullable)createClearPushTokenRequestModel {
    __weak typeof(self) weakSelf = self;
    return [self requestModelWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:[weakSelf.endpoint pushTokenUrlWithApplicationCode:weakSelf.requestContext.applicationCode]];
                [builder setMethod:HTTPMethodDELETE];
                [builder setPayload:@{}];
            }];
}

- (EMSRequestModel *_Nullable)createContactRequestModel {
    __weak typeof(self) weakSelf = self;
    return [self requestModelWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setMethod:HTTPMethodPOST];
                BOOL anonymousLogin = NO;
                NSMutableDictionary *mutablePayload = [NSMutableDictionary dictionary];
                if (weakSelf.requestContext.contactFieldId && [weakSelf.requestContext hasContactIdentification]) {
                    mutablePayload[@"contactFieldId"] = weakSelf.requestContext.contactFieldId;
                    if (weakSelf.requestContext.contactFieldValue) {
                        mutablePayload[@"contactFieldValue"] = weakSelf.requestContext.contactFieldValue;
                    }
                } else {
                    anonymousLogin = YES;
                }
                [builder setUrl:[weakSelf.endpoint contactUrlWithApplicationCode:weakSelf.requestContext.applicationCode]
                queryParameters:@{@"anonymous": anonymousLogin ? @"true" : @"false"}];
                [builder setPayload:[NSDictionary dictionaryWithDictionary:mutablePayload]];
                if (self.predictRequestContext.merchantId) {
                    [builder setHeaders:@{@"X-Merchant-Id": self.predictRequestContext.merchantId}];
                }
            }];
}

- (EMSRequestModel *_Nullable)createPredictOnlyContactRequestModelWithRefresh:(BOOL)shouldRefresh {
    __weak typeof(self) weakSelf = self;
    return [self requestModelWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setMethod:HTTPMethodPOST];
                [builder setUrl:[weakSelf.endpoint contactUrlPredictOnly]];
                if (self.predictRequestContext.merchantId) {
                    [builder setHeaders:@{
                        @"x-merchant-id": self.predictRequestContext.merchantId
                    }];
                }
                NSMutableDictionary *mutablePayload = [NSMutableDictionary dictionary];
        if (shouldRefresh) {
            if (weakSelf.requestContext.refreshToken) {
                mutablePayload[@"refreshToken"] = weakSelf.requestContext.refreshToken;
            }
        } else {
            if (weakSelf.predictRequestContext.contactFieldId && [weakSelf.requestContext hasContactIdentification]) {
                mutablePayload[@"contactFieldId"] = weakSelf.requestContext.contactFieldId;
                if (weakSelf.requestContext.contactFieldValue) {
                    mutablePayload[@"contactFieldValue"] = weakSelf.requestContext.contactFieldValue;
                }
            }

        }
                [builder setPayload:[NSDictionary dictionaryWithDictionary:mutablePayload]];
            }];
}

- (EMSRequestModel *_Nullable)createPredictOnlyClearContactRequestModel {
    __weak typeof(self) weakSelf = self;
    return [self requestModelWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setMethod:HTTPMethodDELETE];
                [builder setUrl:[weakSelf.endpoint contactUrlPredictOnly]];
            }];
}

- (EMSRequestModel *_Nullable)createEventRequestModelWithEventName:(NSString *)eventName
                                          eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes
                                                eventType:(EventType)eventType {
    __weak typeof(self) weakSelf = self;
    return [self requestModelWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setMethod:HTTPMethodPOST];
                [builder setUrl:[weakSelf.endpoint eventUrlWithApplicationCode:weakSelf.requestContext.applicationCode]];

                NSMutableDictionary *mutableEvent = [NSMutableDictionary dictionary];
                mutableEvent[@"type"] = [weakSelf eventTypeStringRepresentationFromEventType:eventType];
                mutableEvent[@"name"] = eventName;
                mutableEvent[@"timestamp"] = [[weakSelf.requestContext.timestampProvider provideTimestamp] stringValueInUTC];
                mutableEvent[@"attributes"] = eventAttributes;
                mutableEvent[@"sessionId"] = self.sessionIdHolder.sessionId;
                NSMutableDictionary *mutablePayload = [NSMutableDictionary dictionary];
                mutablePayload[@"clicks"] = @[];
                mutablePayload[@"viewedMessages"] = @[];
                mutablePayload[@"events"] = @[
                        [NSDictionary dictionaryWithDictionary:mutableEvent]
                ];
                [builder setPayload:[NSDictionary dictionaryWithDictionary:mutablePayload]];
            }];
}

- (EMSRequestModel *_Nullable)createRefreshTokenRequestModel {
    __weak typeof(self) weakSelf = self;
    EMSRequestModel *result;
    if ([MEExperimental isFeatureEnabled:EMSInnerFeature.predict] && ![MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage]) {
        result = [self createPredictOnlyContactRequestModelWithRefresh:YES];
    } else if ([MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage]) {
        result = [self requestModelWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setMethod:HTTPMethodPOST];
            [builder setUrl:[weakSelf.endpoint contactTokenUrlWithApplicationCode:weakSelf.requestContext.applicationCode]];
            NSMutableDictionary *mutablePayload = [NSMutableDictionary dictionary];
            mutablePayload[@"refreshToken"] = weakSelf.requestContext.refreshToken;
            [builder setPayload:[NSDictionary dictionaryWithDictionary:mutablePayload]];
        }];
    }
    return result;
}

- (EMSRequestModel *)createDeepLinkRequestModelWithTrackingId:(NSString *)trackingId {
    __weak typeof(self) weakSelf = self;
    NSString *userAgent = [NSString stringWithFormat:@"Emarsys SDK %@ %@ %@", EMARSYS_SDK_VERSION,
                                                     self.requestContext.deviceInfo.deviceType,
                                                     self.requestContext.deviceInfo.osVersion];
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setMethod:HTTPMethodPOST];
                [builder setUrl:[weakSelf.endpoint deeplinkUrl]];
                [builder setHeaders:@{@"User-Agent": userAgent}];
                [builder setPayload:@{@"ems_dl": trackingId}];
            }
                          timestampProvider:self.requestContext.timestampProvider
                               uuidProvider:self.requestContext.uuidProvider];
}

- (EMSRequestModel *_Nullable)createGeofenceRequestModel {
    __weak typeof(self) weakSelf = self;
    return [self requestModelWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:[weakSelf.endpoint geofenceUrlWithApplicationCode:self.requestContext.applicationCode]];
                [builder setMethod:HTTPMethodGET];
                [builder setHeaders:@{@"Authorization": [EMSAuthentication createBasicAuthWithUsername:self.requestContext.applicationCode]}];
            }];
}

- (EMSRequestModel *_Nullable)createMessageInboxRequestModel {
    __weak typeof(self) weakSelf = self;
    return [self requestModelWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:[weakSelf.endpoint v3MessageInboxUrlApplicationCode:weakSelf.requestContext.applicationCode]];
                [builder setMethod:HTTPMethodGET];
                [builder setHeaders:@{@"Authorization": [EMSAuthentication createBasicAuthWithUsername:weakSelf.requestContext.applicationCode]}];
            }];
}

- (EMSRequestModel *_Nullable)createInlineInappRequestModelWithViewId:(NSString *)viewId {
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    payload[@"viewIds"] = @[viewId];
    payload[@"clicks"] = [self clickRepresentations];
    return [self requestModelWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:[weakSelf.endpoint inlineInappUrlWithApplicationCode:weakSelf.requestContext.applicationCode]];
                [builder setMethod:HTTPMethodPOST];
                [builder setPayload:[NSDictionary dictionaryWithDictionary:payload]];
            }];
}

- (NSString *)eventTypeStringRepresentationFromEventType:(EventType)eventType {
    NSString *result = @"custom";
    if (eventType == EventTypeInternal) {
        result = @"internal";
    }
    return result;
}

- (NSArray *)clickRepresentations {
    NSArray<MEButtonClick *> *buttonModels = [self.buttonClickRepository query:[EMSFilterByNothingSpecification new]];
    NSMutableArray *clicks = [NSMutableArray new];
    for (MEButtonClick *click in buttonModels) {
        [clicks addObject:[click dictionaryRepresentation]];
    }
    return [NSArray arrayWithArray:clicks];
}

- (EMSRequestModel *)requestModelWithBuilder:(EMSRequestBuilderBlock)builderBlock {
    EMSRequestModel *result = nil;
    if (self.requestContext.applicationCode || self.predictRequestContext.merchantId) {
        result = [EMSRequestModel makeWithBuilder:builderBlock
                                timestampProvider:self.requestContext.timestampProvider
                                     uuidProvider:self.requestContext.uuidProvider];
    }
    return result;
}

@end
