//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class MEInApp;
@class EMSPredictInternal;
@class EMSSQLiteHelper;
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
@class MEButtonClickRepository;
@protocol EMSOnEventActionProtocol;
@protocol EMSContactClientProtocol;

@protocol EMSDependencyContainerProtocol <NSObject>

- (EMSSQLiteHelper *)dbHelper;

- (id <EMSMobileEngageProtocol>)mobileEngage;

- (id <EMSMobileEngageProtocol>)loggingMobileEngage;

- (id <EMSContactClientProtocol>)contactClient;

- (id <EMSContactClientProtocol>)loggingContactClient;

- (id <EMSDeepLinkProtocol>)deepLink;

- (id <EMSPushNotificationProtocol>)push;

- (id <EMSPushNotificationProtocol>)loggingPush;

- (id <EMSInAppProtocol, MEIAMProtocol>)iam;

- (id <EMSInAppProtocol, MEIAMProtocol>)loggingIam;

- (id <EMSPredictProtocol, EMSPredictInternalProtocol>)predict;

- (id <EMSPredictProtocol, EMSPredictInternalProtocol>)loggingPredict;

- (id <EMSGeofenceProtocol>)geofence;

- (id <EMSGeofenceProtocol>)loggingGeofence;

- (id <EMSMessageInboxProtocol>)messageInbox;

- (id <EMSMessageInboxProtocol>)loggingMessageInbox;

- (id <EMSConfigProtocol>)config;

- (id <EMSOnEventActionProtocol>)onEventAction;

- (id <EMSOnEventActionProtocol>)loggingOnEventAction;

- (id <EMSRequestModelRepositoryProtocol>)requestRepository;

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

- (MEButtonClickRepository *)buttonClickRepository;

@end
