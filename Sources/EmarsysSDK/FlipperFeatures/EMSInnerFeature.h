//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSFlipperFeatures.h"

@interface EMSInnerFeature : NSObject <EMSFlipperFeature>

@property(class, nonatomic, readonly) id <EMSFlipperFeature> mobileEngage;
@property(class, nonatomic, readonly) id <EMSFlipperFeature> predict;

@end