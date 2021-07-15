//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSPushNotificationProtocol.h"

@class EMSRequestFactory;
@class EMSRequestManager;
@class EMSTimestampProvider;
@class EMSActionFactory;
@class EMSStorage;

@interface EMSPushV3Internal : NSObject <EMSPushNotificationProtocol>

@property(nonatomic, readonly) NSData *deviceToken;
@property(nonatomic, strong) EMSEventHandlerBlock silentMessageEventHandler;
@property(nonatomic, strong) EMSSilentNotificationInformationBlock silentNotificationInformationDelegate;

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                     timestampProvider:(EMSTimestampProvider *)timestampProvider
                         actionFactory:(EMSActionFactory *)actionFactory
                               storage:(EMSStorage *)storage;

- (void)clearDeviceTokenStorage;

@end