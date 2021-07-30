//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInAppTrackingProtocol.h"

@class EMSRequestManager;
@class EMSRequestFactory;
@class MEInApp;
@class EMSTimestampProvider;
@class EMSUUIDProvider;

@interface EMSInAppInternal : NSObject <MEInAppTrackingProtocol>

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                               meInApp:(MEInApp *)meInApp
                     timestampProvider:(EMSTimestampProvider *)timestampProvider
                          uuidProvider:(EMSUUIDProvider *)uuidProvider;

- (void)handleInApp:(NSDictionary *)userInfo
              inApp:(NSDictionary *)inApp;

@end