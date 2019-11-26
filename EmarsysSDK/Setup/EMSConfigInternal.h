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
@class PRERequestContext;
@class EMSDeviceInfo;
@class EMSRequestManager;
@class EMSEmarsysRequestFactory;

@interface EMSConfigInternal : NSObject <EMSConfigProtocol>

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                      meRequestContext:(MERequestContext *)meRequestContext
                     preRequestContext:(PRERequestContext *)preRequestContext
                          mobileEngage:(EMSMobileEngageV3Internal *)mobileEngage
                          pushInternal:(EMSPushV3Internal *)pushInternal
                            deviceInfo:(EMSDeviceInfo *)deviceInfo
                 emarsysRequestFactory:(EMSEmarsysRequestFactory *)emarsysRequestFactory;

- (void)fetchRemoteConfig;

@end