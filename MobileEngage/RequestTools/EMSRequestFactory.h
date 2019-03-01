//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class EMSRequestModel;
@class EMSDeviceInfo;

@interface EMSRequestFactory : NSObject

- (EMSRequestModel *)createDeviceInfoRequestModel;

@end
