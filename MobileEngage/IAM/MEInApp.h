//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSEventHandler.h"
#import "EMSInAppProtocol.h"
#import "MEInApp.h"
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
@class MEButtonClickRepository;

typedef void (^MECompletionHandler)(void);

NS_ASSUME_NONNULL_BEGIN

@interface MEInApp : NSObject <EMSInAppProtocol, MEIAMProtocol>

@property(nonatomic, weak, nullable) id <EMSEventHandler> eventHandler;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, weak, nullable) id <MEInAppTrackingProtocol> inAppTracker;

- (instancetype)initWithWindowProvider:(EMSWindowProvider *)windowProvider
                    mainWindowProvider:(EMSMainWindowProvider *)mainWindowProvider
                     timestampProvider:(EMSTimestampProvider *)timestampProvider
                         logRepository:(MELogRepository *)logRepository
                displayedIamRepository:(MEDisplayedIAMRepository *)displayedIamRepository
                 buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository;

- (UIWindow *)iamWindow;

- (void)setIamWindow:(UIWindow *)window;

- (void)showMessage:(MEInAppMessage *)message
  completionHandler:(MECompletionHandler _Nullable)completionHandler;

- (void)closeInAppMessageWithCompletionBlock:(MECompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END