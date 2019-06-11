//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRequestFromShardsMapperProtocol.h"
#import "MERequestContext.h"

@interface EMSLogMapper : NSObject <EMSRequestFromShardsMapperProtocol>

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext
                    applicationCode:(NSString *)applicationCode
                    merchantId:(NSString *)merchantId;

@end