//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEExperimental.h"


@implementation MEExperimental
static NSMutableSet * _enabledFeatures;

+ (BOOL)isFeatureEnabled:(id <EMSFlipperFeature>)feature {
    return [_enabledFeatures containsObject:feature];
}

+ (void)enableFeature:(id <EMSFlipperFeature>)feature {
    if(_enabledFeatures == nil) {
        _enabledFeatures = [NSMutableSet new];
    }
    [_enabledFeatures addObject:feature];
}

+ (void)disableFeature:(id <EMSFlipperFeature>)feature {
    [_enabledFeatures removeObject:feature];
}

+ (void)reset {
    _enabledFeatures = nil;
}

@end