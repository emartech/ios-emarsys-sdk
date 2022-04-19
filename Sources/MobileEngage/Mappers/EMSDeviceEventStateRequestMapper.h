//
// Copyright (c) 2022 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestModelMapperProtocol.h"

#define kDeviceEventStateKey @"DEVICE_EVENT_STATE_KEY"

@class EMSEndpoint;
@protocol EMSStorageProtocol;

@interface EMSDeviceEventStateRequestMapper: NSObject<EMSRequestModelMapperProtocol>

@property(nonatomic, readonly) EMSEndpoint *endpoint;
@property(nonatomic, readonly) id<EMSStorageProtocol> storage;

- (instancetype)initWithEndpoint:(EMSEndpoint *)endpoint
                         storage:(id <EMSStorageProtocol>)storage;

@end