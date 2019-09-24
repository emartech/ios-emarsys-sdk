//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSConfigProtocol.h"
#import "EMSConfig.h"

@class EMSDeviceInfoV3ClientInternal;
@class EMSMobileEngageV3Internal;
@class MERequestContext;
@class EMSPushV3Internal;

@interface EMSConfigInternal : NSObject <EMSConfigProtocol>

- (instancetype)initWithConfig:(EMSConfig *)config
                requestContext:(MERequestContext *)requestContext
                  mobileEngage:(EMSMobileEngageV3Internal *)mobileEngage
                  pushInternal:(EMSPushV3Internal *)pushInternal;

@end