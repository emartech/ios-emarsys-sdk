//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSConfigBuilder.h"

@implementation EMSConfigBuilder

- (EMSConfigBuilder *)setCredentialsWithApplicationCode:(NSString *)applicationCode
                                   applicationPassword:(NSString *)applicationPassword {
    _applicationCode = applicationCode;
    _applicationPassword = applicationPassword;
    return self;
}

- (EMSConfigBuilder *)setExperimentalFeatures:(NSArray<MEFlipperFeature> *)features {
    _experimentalFeatures = features;
    return self;
}

@end