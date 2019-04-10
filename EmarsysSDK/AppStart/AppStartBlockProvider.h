//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MENotificationCenterManager.h"

@class EMSRequestManager;
@class MERequestContext;
@class EMSRequestFactory;
@protocol EMSDeviceInfoClientProtocol;

@interface AppStartBlockProvider : NSObject

        - (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                                requestFactory:(EMSRequestFactory *)requestFactory
                                requestContext:(MERequestContext *)requestContext
                              deviceInfoClient:(id <EMSDeviceInfoClientProtocol>)deviceInfoClient;

- (MEHandlerBlock)createAppStartEventBlock;

- (MEHandlerBlock)createDeviceInfoEventBlock;

@end