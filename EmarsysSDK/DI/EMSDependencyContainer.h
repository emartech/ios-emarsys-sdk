//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSConfig.h"
#import "EMSDependencyContainerProtocol.h"

@class EMSTimestampProvider;

@interface EMSDependencyContainer : NSObject <EMSDependencyContainerProtocol>

- (instancetype)initWithConfig:(EMSConfig *)config;

@end