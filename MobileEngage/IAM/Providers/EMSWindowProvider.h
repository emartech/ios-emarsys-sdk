//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class EMSViewControllerProvider;
@class EMSSceneProvider;

@interface EMSWindowProvider : NSObject

- (instancetype)initWithViewControllerProvider:(EMSViewControllerProvider *)viewControllerProvider
                                 sceneProvider:(EMSSceneProvider *)sceneProvider;

- (UIWindow *)provideWindow;

@end