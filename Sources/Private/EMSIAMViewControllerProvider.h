//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class MEJSBridge;
@class MEIAMViewController;

@interface EMSIAMViewControllerProvider : NSObject

- (instancetype)initWithJSBridge:(MEJSBridge *)jsBridge;

- (MEIAMViewController *)provideViewController;

@end