//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEEventHandler.h"
#import "EMSInAppProtocol.h"
#import "MEInApp.h"
#import "MobileEngage.h"
#import <UIKit/UIKit.h>
#import "MEInAppMessage.h"
#import "MEInAppTrackingProtocol.h"
#import "MELogRepository.h"
#import "MEIAMProtocol.h"

@class EMSWindowProvider;
@class MEIAMJSCommandFactory;
@class EMSIAMViewControllerProvider;
@class EMSTimestampProvider;
@class MEDisplayedIAMRepository;
@class EMSMainWindowProvider;
@class EMSViewControllerProvider;

typedef void (^MECompletionHandler)(void);

NS_ASSUME_NONNULL_BEGIN

@interface MEInApp : NSObject <EMSInAppProtocol, MEIAMProtocol>

@property(nonatomic, weak, nullable) id <MEEventHandler> eventHandler;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, weak, nullable) id <MEInAppTrackingProtocol> inAppTracker;

- (instancetype)initWithWindowProvider:(EMSWindowProvider *)windowProvider
                    mainWindowProvider:(EMSMainWindowProvider *)mainWindowProvider
                     timestampProvider:(EMSTimestampProvider *)timestampProvider
                         logRepository:(MELogRepository *)logRepository
                displayedIamRepository:(MEDisplayedIAMRepository *)displayedIamRepository;

- (UIWindow *)iamWindow;

- (void)setIamWindow:(UIWindow *)window;

- (void)showMessage:(MEInAppMessage *)message
  completionHandler:(MECompletionHandler _Nullable)completionHandler;

- (void)closeInAppMessageWithCompletionBlock:(MECompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END