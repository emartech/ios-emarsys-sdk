//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class EMSTimestampProvider;
@class EMSUUIDProvider;
@class EMSRequestModel;

@interface EMSEmarsysRequestFactory : NSObject

- (instancetype)initWithTimestampProvider:(EMSTimestampProvider *)timestampProvider
                             uuidProvider:(EMSUUIDProvider *)uuidProvider;

- (EMSRequestModel *)createRemoteConfigRequestModel;

@end