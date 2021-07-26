//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSPushNotificationProtocol.h"
#import "EMSStorage.h"
#import "MEInApp.h"

@class EMSRequestFactory;
@class EMSRequestManager;
@class EMSTimestampProvider;
@class EMSActionFactory;
@class EMSStorage;

@interface EMSPushV3Internal : NSObject <EMSPushNotificationProtocol>

@property(nonatomic, readonly) NSData *deviceToken;
@property(nonatomic, strong) EMSEventHandlerBlock silentMessageEventHandler;
@property(nonatomic, strong) EMSSilentNotificationInformationBlock silentMessageInformationBlock;
@property(nonatomic, strong) EMSEventHandlerBlock notificationEventHandler;
@property(nonatomic, strong) EMSSilentNotificationInformationBlock notificationInformationBlock;

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                     timestampProvider:(EMSTimestampProvider *)timestampProvider
                         actionFactory:(EMSActionFactory *)actionFactory
                               storage:(EMSStorage *)storage
                                 inApp:(MEInApp *)inApp
                          uuidProvider:(EMSUUIDProvider *)uuidProvider
                        operationQueue:(NSOperationQueue *)operationQueue;

- (void)clearDeviceTokenStorage;

@end