//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EMSBlocks.h"

@class EMSConfig;

@interface EMSAppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) EMSEventHandlerBlock eventHandler;
@property(strong, nonatomic) UIWindow *window;

- (EMSConfig *)provideEMSConfig;

@end