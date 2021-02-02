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
static id <EMSFlipperFeature> _eventServiceV4;

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

+ (id <EMSFlipperFeature>)eventServiceV4 {
    if (!_eventServiceV4) {
        _eventServiceV4 = [[EMSInnerFeature alloc] initWithName:@"InnerFeatureEventServiceV4"];
    }
    return _eventServiceV4;
}

@end