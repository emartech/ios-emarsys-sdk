//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class MEInApp;
@class EMSPredictInternal;
@class EMSSQLiteHelper;
@class EMSNotificationCache;
@class EMSAbstractResponseHandler;
@class EMSRequestManager;
@protocol EMSRequestModelRepositoryProtocol;
@protocol EMSInboxProtocol;
@class EMSNotificationCenterManager;
@class MERequestContext;
@class EMSAppStartBlockProvider;
@class MEUserNotificationDelegate;
@class EMSLogger;
@protocol EMSDBTriggerProtocol;
@class EMSRequestFactory;
@protocol EMSMobileEngageProtocol;
@protocol EMSPushNotificationProtocol;
@protocol EMSDeepLinkProtocol;
@protocol EMSDeviceInfoClientProtocol;
@protocol EMSPredictProtocol;
@protocol EMSPredictInternalProtocol;
@protocol EMSUserNotificationCenterDelegate;
@protocol EMSInAppProtocol;
@protocol MEIAMProtocol;
@protocol EMSConfigProtocol;
@class EMSValueProvider;
@protocol EMSGeofenceProtocol;
@protocol EMSMessageInboxProtocol;
@class EMSEndpoint;

@protocol EMSDependencyContainerProtocol <NSObject>

- (EMSSQLiteHelper *)dbHelper;

- (id <EMSMobileEngageProtocol>)mobileEngage;

- (id <EMSMobileEngageProtocol>)loggingMobileEngage;

- (id <EMSDeepLinkProtocol>)deepLink;

- (id <EMSDeepLinkProtocol>)loggingDeepLink;

- (id <EMSPushNotificationProtocol>)push;

- (id <EMSPushNotificationProtocol>)loggingPush;

- (id <EMSInboxProtocol>)inbox;

- (id <EMSInboxProtocol>)loggingInbox;

- (id <EMSInAppProtocol, MEIAMProtocol>)iam;

- (id <EMSInAppProtocol, MEIAMProtocol>)loggingIam;

- (id <EMSPredictProtocol, EMSPredictInternalProtocol>)predict;

- (id <EMSPredictProtocol, EMSPredictInternalProtocol>)loggingPredict;

- (id <EMSUserNotificationCenterDelegate>)notificationCenterDelegate;

- (id <EMSUserNotificationCenterDelegate>)loggingNotificationCenterDelegate;

- (id <EMSGeofenceProtocol>)geofence;

- (id <EMSGeofenceProtocol>)loggingGeofence;

- (id <EMSMessageInboxProtocol>)messageInbox;

- (id <EMSMessageInboxProtocol>)loggingMessageInbox;

- (id <EMSConfigProtocol>)config;

- (id <EMSRequestModelRepositoryProtocol>)requestRepository;

- (EMSNotificationCache *)notificationCache;

- (NSArray<EMSAbstractResponseHandler *> *)responseHandlers;

- (EMSRequestManager *)requestManager;

- (NSOperationQueue *)publicApiOperationQueue;

- (NSOperationQueue *)coreOperationQueue;

- (EMSNotificationCenterManager *)notificationCenterManager;

- (MERequestContext *)requestContext;

- (EMSRequestFactory *)requestFactory;

- (EMSAppStartBlockProvider *)appStartBlockProvider;

- (EMSLogger *)logger;

- (id <EMSDBTriggerProtocol>)predictTrigger;

- (id <EMSDBTriggerProtocol>)loggerTrigger;

- (id <EMSDeviceInfoClientProtocol>)deviceInfoClient;

- (EMSEndpoint *)endpoint;

@end
