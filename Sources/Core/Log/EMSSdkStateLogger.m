//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import "EMSSdkStateLogger.h"
#import "EMSEndpoint.h"
#import "MERequestContext.h"
#import "EMSDeviceInfo.h"
#import "EMSStorage.h"
#import "EMSDeviceEventStateResponseHandler.h"
#import "EMSStorageProtocol.h"


@implementation EMSSdkStateLogger

- (instancetype)initWithEndpoint:(EMSEndpoint *)endpoint
                meRequestContext:(MERequestContext *)meRequestContext
                          config:(EMSConfig *)config
                         storage:(EMSStorage *)storage {
    NSParameterAssert(endpoint);
    NSParameterAssert(meRequestContext);
    NSParameterAssert(config);
    NSParameterAssert(storage);
    if (self = [super init]) {
        _endpoint = endpoint;
        _meRequestContext = meRequestContext;
        _config = config;
        _storage = storage;
    }
    return self;
}

- (void)log {
    NSLog(@"EmarsysSDK - %@ - %@", @"ApplicationCode ", self.meRequestContext.applicationCode);
    NSLog(@"EmarsysSDK - %@ - %@", @"MerchantId ", self.meRequestContext);
    NSLog(@"EmarsysSDK - %@ - %@", @"ExperimentalFeatures ", self.config.experimentalFeatures.description);

    NSLog(@"EmarsysSDK - %@ - %@", @"HardwareId ", self.meRequestContext.deviceInfo.hardwareId);
    NSLog(@"EmarsysSDK - %@ - %@", @"EventServiceUrl ", self.endpoint.eventServiceUrl);
    NSLog(@"EmarsysSDK - %@ - %@", @"ClientServiceUrl ", self.endpoint.clientServiceUrl);
    NSLog(@"EmarsysSDK - %@ - %@", @"DeeplinkUrl ", self.endpoint.deeplinkUrl);
    NSLog(@"EmarsysSDK - %@ - %@", @"PredictServiceUrl ", self.endpoint.predictUrl);

    NSLog(@"EmarsysSDK - %@ - %@", @"ContactToken ", self.meRequestContext.contactToken);
    NSLog(@"EmarsysSDK - %@ - %@", @"RefreshToken ", self.meRequestContext.refreshToken);
    NSLog(@"EmarsysSDK - %@ - %@", @"ClientState ", self.meRequestContext.clientState);
    NSLog(@"EmarsysSDK - %@ - %@", @"ContactFieldId ", self.meRequestContext.contactFieldId);
    NSLog(@"EmarsysSDK - %@ - %@", @"ContactFieldValue ", self.meRequestContext.contactFieldValue);
    NSLog(@"EmarsysSDK - %@ - %@", @"OpenIdToken ", self.meRequestContext.openIdToken);
    NSLog(@"EmarsysSDK - %@ - %@", @"DeviceEventState ", [self.storage dictionaryForKey:kDeviceEventStateKey]);
}

@end