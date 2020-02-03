//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class EMSRemoteConfig;
@class EMSResponseModel;

@interface EMSRemoteConfigResponseMapper : NSObject

- (EMSRemoteConfig *)map:(EMSResponseModel *)responseModel;

@end