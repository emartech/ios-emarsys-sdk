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

- (MEHandlerBlock)createAppStartBlockWithRequestManager:(EMSRequestManager *)requestManager
                                         requestContext:(MERequestContext *)requestContext;

- (MEHandlerBlock)createAppStartBlockWithRequestManager:(EMSRequestManager *)requestManager
                                         requestFactory:(EMSRequestFactory *)requestFactory
                                             deviceInfo:(EMSDeviceInfo *)deviceInfo;
@end