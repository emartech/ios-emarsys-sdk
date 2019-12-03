//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSDependencyContainerProtocol.h"

@interface FakeDependencyContainer : NSObject <EMSDependencyContainerProtocol>

- (instancetype)initWithDbHelper:(EMSSQLiteHelper *)dbHelper
                    mobileEngage:(id <EMSMobileEngageProtocol>)mobileEngage
                        deepLink:(id <EMSDeepLinkProtocol>)deepLink
                            push:(id <EMSPushNotificationProtocol>)push
                           inbox:(id <EMSInboxProtocol>)inbox
                             iam:(MEInApp *)iam
                         predict:(EMSPredictInternal *)predict
                  requestContext:(MERequestContext *)requestContext
                  requestFactory:(EMSRequestFactory *)requestFactory
               requestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
               notificationCache:(EMSNotificationCache *)notificationCache
                responseHandlers:(NSArray<EMSAbstractResponseHandler *> *)responseHandlers
                  requestManager:(EMSRequestManager *)requestManager
                  operationQueue:(NSOperationQueue *)operationQueue
       notificationCenterManager:(MENotificationCenterManager *)notificationCenterManager
           appStartBlockProvider:(AppStartBlockProvider *)appStartBlockProvider
                deviceInfoClient:(id <EMSDeviceInfoClientProtocol>)deviceInfoClient
                          logger:(EMSLogger *)logger;

@end