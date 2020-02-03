//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSConfig.h"
#import "EMSDependencyContainerProtocol.h"

@class EMSTimestampProvider;
@class EMSResponseModel;

@interface EMSDependencyContainer : NSObject <EMSDependencyContainerProtocol>

- (instancetype)initWithConfig:(EMSConfig *)config;

- (void (^)(NSString *, EMSResponseModel *))createSuccessBlock;

@end
