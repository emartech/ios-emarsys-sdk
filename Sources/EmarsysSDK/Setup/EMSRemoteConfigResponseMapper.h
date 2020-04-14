//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class EMSRemoteConfig;
@class EMSResponseModel;
@class EMSRandomProvider;

@interface EMSRemoteConfigResponseMapper : NSObject

@property(nonatomic, readonly) EMSRandomProvider *randomProvider;

- (instancetype)initWithRandomProvider:(EMSRandomProvider *)randomProvider;

- (EMSRemoteConfig *)map:(EMSResponseModel *)responseModel;

@end