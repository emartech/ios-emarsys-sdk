//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSWindowProvider.h"
#import "EMSViewControllerProvider.h"

@interface EMSWindowProvider ()

@property(nonatomic, strong) EMSViewControllerProvider *viewControllerProvider;

@end

@implementation EMSWindowProvider


- (instancetype)initWithViewControllerProvider:(EMSViewControllerProvider *)viewControllerProvider {
    NSParameterAssert(viewControllerProvider);
    if (self = [super init]) {}
    _viewControllerProvider = viewControllerProvider;
    return self;
}

- (UIWindow *)provideWindow {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.backgroundColor = [UIColor clearColor];
    window.windowLevel = UIWindowLevelAlert;
    window.rootViewController = [self.viewControllerProvider provideViewController];
    return window;
}

@end