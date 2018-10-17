//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EMSMainWindowProvider : NSObject

- (instancetype)initWithApplication:(UIApplication *)application;

- (UIWindow *)provideMainWindow;

@end