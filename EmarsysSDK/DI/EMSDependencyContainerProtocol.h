//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class MobileEngageInternal;
@class MEInApp;
@class PredictInternal;
@class EMSSQLiteHelper;
@class EMSNotificationCache;
@class EMSAbstractResponseHandler;
@class EMSRequestManager;
@protocol EMSRequestModelRepositoryProtocol;
@protocol EMSInboxProtocol;
@class MENotificationCenterManager;
@class MERequestContext;
@class AppStartBlockProvider;
@class MEUserNotificationDelegate;
@class EMSLogger;
@protocol EMSDBTriggerProtocol;
@class EMSRequestFactory;

@protocol EMSDependencyContainerProtocol <NSObject>

- (EMSSQLiteHelper *)dbHelper;

- (MobileEngageInternal *)mobileEngage;

- (id <EMSInboxProtocol>)inbox;

- (MEInApp *)iam;

- (PredictInternal *)predict;

- (MEUserNotificationDelegate *)notificationCenterDelegate;

- (id <EMSRequestModelRepositoryProtocol>)requestRepository;

- (EMSNotificationCache *)notificationCache;

- (NSArray<EMSAbstractResponseHandler *> *)responseHandlers;

- (EMSRequestManager *)requestManager;

- (NSOperationQueue *)operationQueue;

- (MENotificationCenterManager *)notificationCenterManager;

- (MERequestContext *)requestContext;

- (EMSRequestFactory *)requestFactory;

- (AppStartBlockProvider *)appStartBlockProvider;

- (EMSLogger *)logger;

- (id <EMSDBTriggerProtocol>)predictTrigger;

- (id <EMSDBTriggerProtocol>)loggerTrigger;

@end
