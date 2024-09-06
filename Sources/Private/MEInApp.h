//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSInAppProtocol.h"
#import "MEInApp.h"
#import <UIKit/UIKit.h>
#import "MEInAppMessage.h"
#import "MEInAppTrackingProtocol.h"
#import "MEIAMProtocol.h"

@class EMSWindowProvider;
@class MEIAMJSCommandFactory;
@class EMSIAMViewControllerProvider;
@class EMSTimestampProvider;
@class MEDisplayedIAMRepository;
@class EMSMainWindowProvider;
@class EMSViewControllerProvider;
@class MEButtonClickRepository;
@class EMSCompletionProvider;

typedef void (^MECompletionHandler)(void);

NS_ASSUME_NONNULL_BEGIN

@interface MEInApp : NSObject <EMSInAppProtocol, MEIAMProtocol>

@property(nonatomic, strong, nullable) EMSEventHandlerBlock eventHandler;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong, nullable) id <MEInAppTrackingProtocol> inAppTracker;

- (instancetype)initWithWindowProvider:(EMSWindowProvider *)windowProvider
                    mainWindowProvider:(EMSMainWindowProvider *)mainWindowProvider
                     timestampProvider:(EMSTimestampProvider *)timestampProvider
               completionBlockProvider:(EMSCompletionProvider *)completionBlockProvider
                displayedIamRepository:(MEDisplayedIAMRepository *)displayedIamRepository
                 buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
                        operationQueue:(NSOperationQueue *)operationQueue;

- (UIWindow *)iamWindow;

- (void)setIamWindow:(UIWindow *_Nullable)window;

- (void)showMessage:(MEInAppMessage *)message
  completionHandler:(MECompletionHandler _Nullable)completionHandler;

- (void)closeInAppWithCompletionHandler:(_Nullable EMSCompletion)completionHandler;

@end

NS_ASSUME_NONNULL_END
