//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class MEJSBridge;

typedef void (^MECompletionHandler)(void);

@interface MEIAMViewController : UIViewController

- (instancetype)initWithJSBridge:(MEJSBridge *)bridge;

- (void)loadMessage:(NSString *)message
  completionHandler:(MECompletionHandler)completionHandler;

@end
