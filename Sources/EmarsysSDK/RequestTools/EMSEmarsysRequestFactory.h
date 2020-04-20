//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class EMSTimestampProvider;
@class EMSUUIDProvider;
@class EMSRequestModel;
@class EMSEndpoint;
@class MERequestContext;

@interface EMSEmarsysRequestFactory : NSObject

- (instancetype)initWithTimestampProvider:(EMSTimestampProvider *)timestampProvider
                             uuidProvider:(EMSUUIDProvider *)uuidProvider
                                 endpoint:(EMSEndpoint *)endpoint
                           requestContext:(MERequestContext *)requestContext;

- (EMSRequestModel *)createRemoteConfigRequestModel;
- (EMSRequestModel *)createRemoteConfigSignatureRequestModel;

@end