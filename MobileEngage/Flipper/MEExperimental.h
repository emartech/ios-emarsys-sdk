//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSFlipperFeatures.h"

@interface MEExperimental : NSObject

+ (BOOL)isFeatureEnabled:(EMSFlipperFeature)feature;

+ (void)enableFeature:(EMSFlipperFeature)feature;

+ (void)enableFeatures:(NSArray<EMSFlipperFeature> *)features;

@end