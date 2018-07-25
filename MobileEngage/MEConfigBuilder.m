//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEConfigBuilder.h"

@implementation MEConfigBuilder

- (MEConfigBuilder *)setCredentialsWithApplicationCode:(NSString *)applicationCode
                                   applicationPassword:(NSString *)applicationPassword {
    _applicationCode = applicationCode;
    _applicationPassword = applicationPassword;
    return self;
}

- (MEConfigBuilder *)setExperimentalFeatures:(NSArray<MEFlipperFeature> *)features {
    _experimentalFeatures = features;
    return self;
}

@end