//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSDate+EMSCore.h"
#import "EMSTimestampProvider.h"
#import "MEInApp.h"
#import "MEIAMViewController.h"
#import "MEDisplayedIAMRepository.h"
#import "EMSWindowProvider.h"
#import "EMSIAMViewControllerProvider.h"
#import "EMSMainWindowProvider.h"
#import "MEIAMJSCommandFactory.h"
#import "MEJSBridge.h"
#import "MEButtonClickRepository.h"
#import "EMSMacros.h"
#import "EMSCompletionBlockProvider.h"
#import "EMSInAppLog.h"

@interface MEInApp () <MEIAMProtocol>

@property(nonatomic, weak) MEInAppMessage *currentInAppMessage;

@property(nonatomic, strong, nullable) UIWindow *iamWindow;
@property(nonatomic, strong) NSDate *onScreenShowTimestamp;
@property(nonatomic, strong) EMSWindowProvider *windowProvider;
@property(nonatomic, strong) EMSIAMViewControllerProvider *iamViewControllerProvider;
@property(nonatomic, strong) MEDisplayedIAMRepository *displayedIamRepository;
@property(nonatomic, strong) EMSCompletionBlockProvider *completionBlockProvider;

@property(nonatomic, strong) EMSInAppLog *inAppLog;

@property(nonatomic, assign) BOOL paused;

@end

@implementation MEInApp

#pragma mark - Public methods

- (instancetype)initWithWindowProvider:(EMSWindowProvider *)windowProvider
                    mainWindowProvider:(EMSMainWindowProvider *)mainWindowProvider
                     timestampProvider:(EMSTimestampProvider *)timestampProvider
               completionBlockProvider:(EMSCompletionBlockProvider *)completionBlockProvider
                displayedIamRepository:(MEDisplayedIAMRepository *)displayedIamRepository
                 buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository {
    NSParameterAssert(windowProvider);
    NSParameterAssert(mainWindowProvider);
    NSParameterAssert(timestampProvider);
    NSParameterAssert(completionBlockProvider);
    NSParameterAssert(displayedIamRepository);
    NSParameterAssert(buttonClickRepository);
    if (self = [super init]) {
        _timestampProvider = timestampProvider;
        _completionBlockProvider = completionBlockProvider;
        _windowProvider = windowProvider;
        _iamViewControllerProvider = [[EMSIAMViewControllerProvider alloc] initWithJSBridge:[[MEJSBridge alloc] initWithJSCommandFactory:[[MEIAMJSCommandFactory alloc] initWithMEIAM:self
                                                                                                                                                                buttonClickRepository:buttonClickRepository]]];
        _displayedIamRepository = displayedIamRepository;
    }
    return self;
}


- (void)pause {
    [self setPaused:YES];
}

- (void)resume {
    [self setPaused:NO];
}

- (BOOL)isPaused {
    return [self paused];
}

- (void)showMessage:(MEInAppMessage *)message
  completionHandler:(MECompletionHandler)completionHandler {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!weakSelf.iamWindow) {
            weakSelf.inAppLog = nil;
            weakSelf.iamWindow = [weakSelf.windowProvider provideWindow];
            weakSelf.currentInAppMessage = message;
            MEIAMViewController *meiamViewController = [weakSelf.iamViewControllerProvider provideViewController];
            [meiamViewController loadMessage:message.html
                           completionHandler:^{
                               if (message.response && weakSelf.timestampProvider) {
                                   weakSelf.inAppLog = [[EMSInAppLog alloc] initWithMessage:message
                                                                             loadingTimeEnd:[weakSelf.timestampProvider provideTimestamp]];
                               }
                               [weakSelf displayInAppViewController:message
                                                     viewController:meiamViewController];
                               if (completionHandler) {
                                   completionHandler();
                               }
                           }];
        }
    });
}

#pragma mark - Private methods

- (void)displayInAppViewController:(MEInAppMessage *)message
                    viewController:(MEIAMViewController *)meiamViewController {
    [self.iamWindow makeKeyAndVisible];

    __weak typeof(self) weakSelf = self;
    [self.iamWindow.rootViewController presentViewController:meiamViewController
                                                    animated:YES
                                                  completion:[self.completionBlockProvider provideCompletion:^{
                                                      [weakSelf.inAppLog setOnScreenTimeStart:[weakSelf.timestampProvider provideTimestamp]];
                                                      [weakSelf trackIAMDisplay:message];
                                                  }]];
}

- (void)trackIAMDisplay:(MEInAppMessage *)message {
    [self.displayedIamRepository add:[[MEDisplayedIAM alloc] initWithCampaignId:message.campaignId
                                                                      timestamp:[self.timestampProvider provideTimestamp]]];
    [self.inAppTracker trackInAppDisplay:message];
}

- (void)closeInAppMessageWithCompletionBlock:(MECompletionHandler)completionHandler {
    __weak typeof(self) weakSelf = self;
    [self.iamWindow.rootViewController dismissViewControllerAnimated:YES
                                                          completion:^{
                                                              if (weakSelf.currentInAppMessage && weakSelf.onScreenShowTimestamp && weakSelf.timestampProvider) {
                                                                  [weakSelf.inAppLog setOnScreenTimeEnd:[weakSelf.timestampProvider provideTimestamp]];
                                                                  EMSLog(weakSelf.inAppLog, LogLevelInfo);
                                                              }
                                                              [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
                                                              weakSelf.iamWindow = nil;
                                                              if (completionHandler) {
                                                                  completionHandler();
                                                              }
                                                          }];
}

@end
