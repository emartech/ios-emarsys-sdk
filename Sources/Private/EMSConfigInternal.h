//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSConfigProtocol.h"
#import "EMSConfig.h"

@protocol EMSDeviceInfoClientProtocol;
@protocol EMSPushNotificationProtocol;
@protocol EMSContactClientProtocol;
@class MERequestContext;
@class EMSPushV3Internal;
@class PRERequestContext;
@class EMSDeviceInfo;
@class EMSRequestManager;
@class EMSEmarsysRequestFactory;
@class EMSRemoteConfigResponseMapper;
@class EMSEndpoint;
@class EMSLogger;
@class EMSCrypto;
@class EMSDispatchWaiter;

NS_ASSUME_NONNULL_BEGIN

@interface EMSConfigInternal : NSObject <EMSConfigProtocol>

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                      meRequestContext:(MERequestContext *)meRequestContext
                     preRequestContext:(PRERequestContext *)preRequestContext
                         contactClient:(id <EMSContactClientProtocol>)contactClient
                          pushInternal:(id <EMSPushNotificationProtocol>)pushInternal
                            deviceInfo:(EMSDeviceInfo *)deviceInfo
                 emarsysRequestFactory:(EMSEmarsysRequestFactory *)emarsysRequestFactory
            remoteConfigResponseMapper:(EMSRemoteConfigResponseMapper *)remoteConfigResponseMapper
                              endpoint:(EMSEndpoint *)endpoint
                                logger:(EMSLogger *)logger
                                crypto:(EMSCrypto *)crypto
                                 queue:(NSOperationQueue *)queue
                                waiter:(EMSDispatchWaiter *)waiter
                      deviceInfoClient:(id <EMSDeviceInfoClientProtocol>)deviceInfoClient;

- (void)refreshConfigFromRemoteConfigWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
