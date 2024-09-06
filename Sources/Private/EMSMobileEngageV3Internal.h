//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSMobileEngageProtocol.h"

@class EMSRequestFactory;
@class EMSRequestManager;

@interface EMSMobileEngageV3Internal : NSObject <EMSMobileEngageProtocol>

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager;

@end
