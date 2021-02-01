//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSInnerFeature.h"

@interface EMSInnerFeature ()

@property(nonatomic, strong) NSString *name;

@end

@implementation EMSInnerFeature

static id <EMSFlipperFeature> _mobileEngage;
static id <EMSFlipperFeature> _predict;
static id <EMSFlipperFeature> _v4;

- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        _name = name;
    }
    return self;
}

+ (id <EMSFlipperFeature>)mobileEngage {
    if (!_mobileEngage) {
        _mobileEngage = [[EMSInnerFeature alloc] initWithName:@"InnerFeatureMobileEngage"];
    }
    return _mobileEngage;
}

+ (id <EMSFlipperFeature>)predict {
    if (!_predict) {
        _predict = [[EMSInnerFeature alloc] initWithName:@"InnerFeaturePredict"];
    }
    return _predict;
}

+ (id <EMSFlipperFeature>)v4 {
    if (!_v4) {
        _v4 = [[EMSInnerFeature alloc] initWithName:@"InnerFeatureV4"];
    }
    return _v4;
}

@end