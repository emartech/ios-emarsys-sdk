//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSConfigProtocol.h"
#import "EMSConfig.h"

@protocol EMSDeviceInfoClientProtocol;
@protocol EMSPushNotificationProtocol;
@protocol EMSMobileEngageProtocol;
@class EMSMobileEngageV3Internal;
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
                          mobileEngage:(id <EMSMobileEngageProtocol>)mobileEngage
                          pushInternal:(id <EMSPushNotificationProtocol>)pushInternal
                            deviceInfo:(EMSDeviceInfo *)deviceInfo
                 emarsysRequestFactory:(EMSEmarsysRequestFactory *)emarsysRequestFactory
            remoteConfigResponseMapper:(EMSRemoteConfigResponseMapper *)remoteConfigResponseMapper
                              endpoint:(EMSEndpoint *)endpoint
                                logger:(EMSLogger *)logger
                                crypto:(EMSCrypto *)crypto
                             coreQueue:(NSOperationQueue *)coreQueue
                                waiter:(EMSDispatchWaiter *)waiter
                      deviceInfoClient:(id <EMSDeviceInfoClientProtocol>)deviceInfoClient;

- (void)refreshConfigFromRemoteConfigWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
