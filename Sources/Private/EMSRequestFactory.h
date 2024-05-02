//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class EMSRequestModel;
@class MERequestContext;
@class PRERequestContext;
@class EMSDeviceInfo;
@class EMSEndpoint;
@class MEButtonClickRepository;
@class EMSSessionIdHolder;
@protocol EMSStorageProtocol;

typedef enum {
    EventTypeInternal,
    EventTypeCustom
} EventType;

NS_ASSUME_NONNULL_BEGIN

@interface EMSRequestFactory : NSObject

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext
                 predictRequestContext:(PRERequestContext *)predictRequestContext
                              endpoint:(EMSEndpoint *)endpoint
                 buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
                       sessionIdHolder:(EMSSessionIdHolder *)sessionIdHolder
                               storage:(id <EMSStorageProtocol>)storage;

- (EMSRequestModel *_Nullable)createDeviceInfoRequestModel;

- (EMSRequestModel *_Nullable)createPushTokenRequestModelWithPushToken:(NSString *)pushToken;

- (EMSRequestModel *_Nullable)createClearPushTokenRequestModel;

- (EMSRequestModel *_Nullable)createContactRequestModel;

- (EMSRequestModel *_Nullable)createClearContactRequestModel;

- (EMSRequestModel *_Nullable)createPredictOnlyContactRequestModelWithRefresh:(BOOL)shouldRefresh;

- (EMSRequestModel *_Nullable)createPredictOnlyClearContactRequestModel;

- (EMSRequestModel *_Nullable)createEventRequestModelWithEventName:(NSString *)eventName
                                                   eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes
                                                         eventType:(EventType)eventType;

- (EMSRequestModel *_Nullable)createRefreshTokenRequestModel;

- (EMSRequestModel *)createDeepLinkRequestModelWithTrackingId:(NSString *)trackingId;

- (EMSRequestModel *_Nullable)createGeofenceRequestModel;

- (EMSRequestModel *_Nullable)createMessageInboxRequestModel;

- (EMSRequestModel *_Nullable)createInlineInappRequestModelWithViewId:(NSString *)viewId;

@end

NS_ASSUME_NONNULL_END
