//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEExperimental.h"


@implementation MEExperimental
static NSMutableSet * _enabledFeatures;

+ (BOOL)isFeatureEnabled:(EMSFlipperFeature)feature {
    return [_enabledFeatures containsObject:feature];
}

+ (void)enableFeature:(EMSFlipperFeature)feature {
    if(_enabledFeatures == nil) {
        _enabledFeatures = [NSMutableSet new];
    }
    [_enabledFeatures addObject:feature];
}

+ (void)enableFeatures:(NSArray<EMSFlipperFeature> *)features {
    for (EMSFlipperFeature feature in features) {
        [MEExperimental enableFeature:feature];
    }
}

+ (void)reset {
    _enabledFeatures = nil;
}

@end