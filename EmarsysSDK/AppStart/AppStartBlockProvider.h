//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MENotificationCenterManager.h"

@class EMSRequestManager;
@class MERequestContext;

@interface AppStartBlockProvider : NSObject

- (MEHandlerBlock)createAppStartBlockWithRequestManager:(EMSRequestManager *)requestManager
                                         requestContext:(MERequestContext *)requestContext;

@end