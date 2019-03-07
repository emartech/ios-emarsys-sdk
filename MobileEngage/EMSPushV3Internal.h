//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSPushNotificationProtocol.h"

@class EMSRequestFactory;
@class EMSRequestManager;

@interface EMSPushV3Internal : NSObject <EMSPushNotificationProtocol>

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager;

@end