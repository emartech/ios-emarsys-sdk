//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSDeviceInfoClientProtocol.h"

@class EMSRequestManager;
@class EMSRequestFactory;
@class EMSDeviceInfo;
@class MERequestContext;

#define kDEVICE_INFO @"kDEVICE_INFO"

@interface EMSDeviceInfoV3ClientInternal : NSObject <EMSDeviceInfoClientProtocol>

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                            deviceInfo:(EMSDeviceInfo *)deviceInfo
                        requestContext:(MERequestContext *)requestContext;

@end