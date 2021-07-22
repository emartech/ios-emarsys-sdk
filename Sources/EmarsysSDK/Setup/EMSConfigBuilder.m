//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSConfigBuilder.h"

@implementation EMSConfigBuilder

- (EMSConfigBuilder *)setMobileEngageApplicationCode:(NSString *)applicationCode {
    _applicationCode = applicationCode;
    return self;
}

- (EMSConfigBuilder *)setExperimentalFeatures:(NSArray<id <EMSFlipperFeature>> *)features {
    _experimentalFeatures = features;
    return self;
}

- (EMSConfigBuilder *)enableConsoleLogLevels:(NSArray *)consoleLogLevels {
    _enabledConsoleLogLevels = consoleLogLevels;
    return self;
}

- (EMSConfigBuilder *)setMerchantId:(NSString *)merchantId {
    _merchantId = merchantId;
    return self;
}

- (EMSConfigBuilder *)setSharedKeychainAccessGroup:(NSString *)sharedKeychainAccessGroup {
    _sharedKeychainAccessGroup = sharedKeychainAccessGroup;
    return self;
}

@end
