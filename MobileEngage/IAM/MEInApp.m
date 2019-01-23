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

@interface MEInApp () <MEIAMProtocol>

@property(nonatomic, weak) NSString *currentCampaignId;

@property(nonatomic, strong) UIWindow *iamWindow;
@property(nonatomic, strong) NSDate *onScreenShowTimestamp;
@property(nonatomic, strong) EMSWindowProvider *windowProvider;
@property(nonatomic, strong) EMSIAMViewControllerProvider *iamViewControllerProvider;
@property(nonatomic, strong) MELogRepository *logRepository;
@property(nonatomic, strong) MEDisplayedIAMRepository *displayedIamRepository;

@property(nonatomic, assign) BOOL paused;

@end

@implementation MEInApp

#pragma mark - Public methods

- (instancetype)initWithWindowProvider:(EMSWindowProvider *)windowProvider
                    mainWindowProvider:(EMSMainWindowProvider *)mainWindowProvider
                     timestampProvider:(EMSTimestampProvider *)timestampProvider
                         logRepository:(MELogRepository *)logRepository
                displayedIamRepository:(MEDisplayedIAMRepository *)displayedIamRepository
                 buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository {
    NSParameterAssert(windowProvider);
    NSParameterAssert(mainWindowProvider);
    NSParameterAssert(timestampProvider);
    NSParameterAssert(logRepository);
    NSParameterAssert(displayedIamRepository);
    NSParameterAssert(buttonClickRepository);
    if (self = [super init]) {
        _timestampProvider = timestampProvider;
        _logRepository = logRepository;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.iamWindow) {
            self.iamWindow = [self.windowProvider provideWindow];
            self.currentCampaignId = message.campaignId;
            MEIAMViewController *meiamViewController = [self.iamViewControllerProvider provideViewController];
            __weak typeof(self) weakSelf = self;
            [meiamViewController loadMessage:message.html
                           completionHandler:^{
                               if (message.response && weakSelf.timestampProvider) {
                                   NSDictionary *const loadingMetric = @{
                                       @"loading_time": [[weakSelf.timestampProvider provideTimestamp] numberValueInMillisFromDate:message.response.timestamp],
                                       @"id": message.campaignId};
                                   [weakSelf.logRepository add:loadingMetric];

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
                                                  completion:^{
                                                      weakSelf.onScreenShowTimestamp = [weakSelf.timestampProvider provideTimestamp];
                                                      [weakSelf trackIAMDisplay:message];
                                                  }];
}

- (void)trackIAMDisplay:(MEInAppMessage *)message {
    [self.displayedIamRepository add:[[MEDisplayedIAM alloc] initWithCampaignId:message.campaignId
                                                                      timestamp:[self.timestampProvider provideTimestamp]]];
    [self.inAppTracker trackInAppDisplay:message.campaignId];
}

- (void)closeInAppMessageWithCompletionBlock:(MECompletionHandler)completionHandler {
    __weak typeof(self) weakSelf = self;
    [self.iamWindow.rootViewController dismissViewControllerAnimated:YES
                                                          completion:^{
                                                              if (weakSelf.currentCampaignId && weakSelf.onScreenShowTimestamp && weakSelf.timestampProvider) {
                                                                  NSDictionary *const onScreenMetrics = @{
                                                                      @"on_screen_time": [[weakSelf.timestampProvider provideTimestamp] numberValueInMillisFromDate:weakSelf.onScreenShowTimestamp],
                                                                      @"id": weakSelf.currentCampaignId};
                                                                  [weakSelf.logRepository add:onScreenMetrics];

                                                              }
                                                              [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
                                                              weakSelf.iamWindow = nil;
                                                              if (completionHandler) {
                                                                  completionHandler();
                                                              }
                                                          }];
}


@end