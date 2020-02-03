//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSMainWindowProvider.h"

@interface EMSMainWindowProvider ()

@property(nonatomic, strong) UIApplication *application;

@end

@implementation EMSMainWindowProvider

- (instancetype)initWithApplication:(UIApplication *)application {
    NSParameterAssert(application);
    if (self = [super init]) {
        _application = application;
    }
    return self;
}

- (UIWindow *)provideMainWindow {
    return [[_application delegate] window];
}


@end