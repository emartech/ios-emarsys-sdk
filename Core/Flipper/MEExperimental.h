//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSFlipperFeatures.h"

@interface MEExperimental : NSObject

+ (BOOL)isFeatureEnabled:(id <EMSFlipperFeature>)feature;

+ (void)enableFeature:(id <EMSFlipperFeature>)feature;

+ (void)disableFeature:(id <EMSFlipperFeature>)feature;

@end