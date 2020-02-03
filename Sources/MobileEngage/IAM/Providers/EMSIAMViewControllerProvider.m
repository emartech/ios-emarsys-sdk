//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSIAMViewControllerProvider.h"
#import "MEJSBridge.h"
#import "MEIAMViewController.h"

@interface EMSIAMViewControllerProvider ()

@property(nonatomic, strong) MEJSBridge *jsBridge;

@end

@implementation EMSIAMViewControllerProvider

- (instancetype)initWithJSBridge:(MEJSBridge *)jsBridge {
    NSParameterAssert(jsBridge);
    if (self = [super init]) {
        _jsBridge = jsBridge;
    }
    return self;
}

- (MEIAMViewController *)provideViewController {
    return [[MEIAMViewController alloc] initWithJSBridge:self.jsBridge];
}


@end