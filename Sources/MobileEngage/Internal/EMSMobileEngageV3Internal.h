//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSMobileEngageProtocol.h"

@class EMSRequestFactory;
@class EMSRequestManager;
@class MERequestContext;
@class EMSStorage;

@interface EMSMobileEngageV3Internal : NSObject <EMSMobileEngageProtocol>

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                        requestContext:(MERequestContext *)requestContext
                               storage:(EMSStorage *)storage;

@end
