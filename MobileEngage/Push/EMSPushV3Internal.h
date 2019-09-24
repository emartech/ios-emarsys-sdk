//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSPushNotificationProtocol.h"

@class EMSRequestFactory;
@class EMSRequestManager;
@class EMSNotificationCache;
@class EMSTimestampProvider;

@interface EMSPushV3Internal : NSObject <EMSPushNotificationProtocol>

@property (nonatomic, readonly) NSData *deviceToken;

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                     notificationCache:(EMSNotificationCache*) notificationCache
                     timestampProvider:(EMSTimestampProvider *) timestampProvider;

@end