//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSConfigBuilder.h"

@implementation EMSConfigBuilder

- (EMSConfigBuilder *)setMobileEngageApplicationCode:(NSString *)applicationCode
                                 applicationPassword:(NSString *)applicationPassword {
    _applicationCode = applicationCode;
    _applicationPassword = applicationPassword;
    return self;
}

- (EMSConfigBuilder *)setExperimentalFeatures:(NSArray<MEFlipperFeature> *)features {
    _experimentalFeatures = features;
    return self;
}

- (EMSConfigBuilder *)setMerchantId:(NSString *)merchantId {
    _merchantId = merchantId;
    return self;
}

- (EMSConfigBuilder *)setContactFieldId:(NSNumber *)contactFieldId {
    _contactFieldId = contactFieldId;
    return self;
}
@end