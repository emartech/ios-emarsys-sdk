//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MENotificationCenterManager.h"

@class EMSRequestManager;
@class MERequestContext;
@class EMSDeviceInfo;
@class EMSRequestFactory;

#define kDEVICE_INFO @"kDEVICE_INFO"

@interface AppStartBlockProvider : NSObject

        - (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                                requestFactory:(EMSRequestFactory *)requestFactory
                                requestContext:(MERequestContext *)requestContext
                                    deviceInfo:(EMSDeviceInfo *)deviceInfo;


- (MEHandlerBlock)createAppStartEventBlock;

- (MEHandlerBlock)createDeviceInfoEventBlock;

@end