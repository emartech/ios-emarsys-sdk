//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSWindowProvider.h"
#import "EMSViewControllerProvider.h"
#import "EMSSceneProvider.h"

@interface EMSWindowProvider ()

@property(nonatomic, strong) EMSViewControllerProvider *viewControllerProvider;
@property(nonatomic, strong) EMSSceneProvider *sceneProvider;

@end

@implementation EMSWindowProvider


- (instancetype)initWithViewControllerProvider:(EMSViewControllerProvider *)viewControllerProvider
                                 sceneProvider:(EMSSceneProvider *)sceneProvider {
    NSParameterAssert(viewControllerProvider);
    NSParameterAssert(sceneProvider);
    if (self = [super init]) {
        _viewControllerProvider = viewControllerProvider;
        _sceneProvider = sceneProvider;
    }
    return self;
}

- (UIWindow *)provideWindow {
    UIWindow *window;
    if (@available(iOS 13.0, *)) {
        window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *) [self.sceneProvider provideScene]];
    } else {
        window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    window.backgroundColor = [UIColor clearColor];
    window.windowLevel = UIWindowLevelAlert;
    window.rootViewController = [self.viewControllerProvider provideViewController];
    return window;
}

@end