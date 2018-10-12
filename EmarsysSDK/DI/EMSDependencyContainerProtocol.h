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

@protocol EMSDependencyContainerProtocol <NSObject>

- (EMSSQLiteHelper *)dbHelper;

- (MobileEngageInternal *)mobileEngage;

- (id <EMSInboxProtocol>)inbox;

- (MEInApp *)iam;

- (PredictInternal *)predict;

- (id <EMSRequestModelRepositoryProtocol>)requestRepository;

- (EMSNotificationCache *)notificationCache;

- (NSArray<EMSAbstractResponseHandler *> *)responseHandlers;

- (EMSRequestManager *)requestManager;

- (NSOperationQueue *)operationQueue;

- (MENotificationCenterManager *)notificationCenterManager;

- (MERequestContext *)requestContext;

- (AppStartBlockProvider *)appStartBlockProvider;

@end