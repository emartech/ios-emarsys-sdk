//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class EMSTimestampProvider;
@class EMSUUIDProvider;
@class EMSRequestModel;
@class EMSEndpoint;
@class MERequestContext;

NS_ASSUME_NONNULL_BEGIN

@interface EMSEmarsysRequestFactory : NSObject

- (instancetype)initWithTimestampProvider:(EMSTimestampProvider *)timestampProvider
                             uuidProvider:(EMSUUIDProvider *)uuidProvider
                                 endpoint:(EMSEndpoint *)endpoint
                           requestContext:(MERequestContext *)requestContext;

- (EMSRequestModel * _Nullable)createRemoteConfigRequestModel;
- (EMSRequestModel * _Nullable)createRemoteConfigSignatureRequestModel;

@end

NS_ASSUME_NONNULL_END
