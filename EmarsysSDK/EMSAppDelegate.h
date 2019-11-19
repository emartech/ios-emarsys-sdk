//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <EmarsysSDK/EMSEventHandler.h>

@class EMSConfig;

@interface EMSAppDelegate : UIResponder <UIApplicationDelegate, EMSEventHandler>

@property (strong, nonatomic) UIWindow *window;

- (EMSConfig *)provideEMSConfig;

@end
