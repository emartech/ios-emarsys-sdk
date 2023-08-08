//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSDeepLinkProtocol.h"

@class EMSRequestFactory;
@class EMSRequestManager;

@interface EMSDeepLinkInternal : NSObject <EMSDeepLinkProtocol>

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory;

@end