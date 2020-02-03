//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInAppTrackingProtocol.h"

@class EMSRequestManager;
@class EMSRequestFactory;

@interface EMSInAppInternal : NSObject <MEInAppTrackingProtocol>

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory;

@end