//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "EMSViewControllerProvider.h"


@implementation EMSViewControllerProvider

- (UIViewController *)provideViewController {
    UIViewController *viewController = [UIViewController new];
    viewController.view.backgroundColor = [UIColor clearColor];
    return viewController;
}

@end