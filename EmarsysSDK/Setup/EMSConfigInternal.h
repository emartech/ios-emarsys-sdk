//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSConfigProtocol.h"
#import "EMSConfig.h"

@class EMSDeviceInfoV3ClientInternal;
@class EMSMobileEngageV3Internal;
@class MERequestContext;

@interface EMSConfigInternal : NSObject <EMSConfigProtocol>

- (instancetype)initWithConfig:(EMSConfig *)config
                requestContext:(MERequestContext *)requestContext
              deviceInfoClient:(EMSDeviceInfoV3ClientInternal *)deviceInfoClient
                  mobileEngage:(EMSMobileEngageV3Internal *)mobileEngage;

@end