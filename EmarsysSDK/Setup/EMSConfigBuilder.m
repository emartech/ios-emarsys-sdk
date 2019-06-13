//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSConfigBuilder.h"
#import "EMSFlipperFeatures.h"

@implementation EMSConfigBuilder

- (EMSConfigBuilder *)setMobileEngageApplicationCode:(NSString *)applicationCode {
    _applicationCode = applicationCode;
    return self;
}

- (EMSConfigBuilder *)setExperimentalFeatures:(NSArray<EMSFlipperFeature> *)features {
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