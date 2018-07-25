//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEFlipperFeatures.h"

@interface MEExperimental : NSObject

+ (BOOL)isFeatureEnabled:(MEFlipperFeature)feature;
+ (void)enableFeature:(MEFlipperFeature)feature;
+ (void)enableFeatures:(NSArray<MEFlipperFeature> *)features;

@end