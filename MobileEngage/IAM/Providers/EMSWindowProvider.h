//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class EMSViewControllerProvider;

@interface EMSWindowProvider : NSObject
- (instancetype)initWithViewControllerProvider:(EMSViewControllerProvider *)viewControllerProvider;

- (UIWindow *)provideWindow;

@end