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
#import "EMSCompletionProvider.h"
#import "EMSInAppLog.h"

@interface MEInApp () <MEIAMProtocol>

@property(nonatomic, weak) MEInAppMessage *currentInAppMessage;

@property(nonatomic, strong, nullable) UIWindow *iamWindow;
@property(nonatomic, strong, nullable) UIWindow *originalWindow;
@property(nonatomic, strong) EMSWindowProvider *windowProvider;
@property(nonatomic, strong) EMSIAMViewControllerProvider *iamViewControllerProvider;
@property(nonatomic, strong) MEDisplayedIAMRepository *displayedIamRepository;
@property(nonatomic, strong) EMSCompletionProvider *completionBlockProvider;
@property(nonatomic, strong) EMSEventHandlerBlock innerEventHandler;
@property(nonatomic, strong) NSMutableArray<MEInAppMessage *> *messages;

@property(nonatomic, strong) EMSInAppLog *inAppLog;

@property(nonatomic, assign) BOOL paused;

@end

@implementation MEInApp

#pragma mark - Public methods

- (instancetype)initWithWindowProvider:(EMSWindowProvider *)windowProvider
                    mainWindowProvider:(EMSMainWindowProvider *)mainWindowProvider
                     timestampProvider:(EMSTimestampProvider *)timestampProvider
               completionBlockProvider:(EMSCompletionProvider *)completionBlockProvider
                displayedIamRepository:(MEDisplayedIAMRepository *)displayedIamRepository
                 buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
                        operationQueue:(NSOperationQueue *)operationQueue {
    NSParameterAssert(windowProvider);
    NSParameterAssert(mainWindowProvider);
    NSParameterAssert(timestampProvider);
    NSParameterAssert(completionBlockProvider);
    NSParameterAssert(displayedIamRepository);
    NSParameterAssert(buttonClickRepository);
    NSParameterAssert(operationQueue);
    if (self = [super init]) {
        _timestampProvider = timestampProvider;
        _completionBlockProvider = completionBlockProvider;
        _windowProvider = windowProvider;
        __weak typeof(self) weakSelf = self;
        _innerEventHandler = ^(NSString *eventName, NSDictionary<NSString *, id> *payload) {
            if (weakSelf.eventHandler) {
                weakSelf.eventHandler(eventName, payload);
            }
        };
        _iamViewControllerProvider = [[EMSIAMViewControllerProvider alloc] initWithJSBridge:[[MEJSBridge alloc] initWithJSCommandFactory:[[MEIAMJSCommandFactory alloc] initWithMEIAM:self
                                                                                                                                                                buttonClickRepository:buttonClickRepository
                                                                                                                                                                 appEventHandlerBlock:self.innerEventHandler
                                                                                                                                                                        closeProtocol:self
                                                                                                                                                                           pasteboard:[UIPasteboard generalPasteboard]]
                                                                                                                          operationQueue:operationQueue]];
        _displayedIamRepository = displayedIamRepository;
        _messages = [NSMutableArray array];
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
        } else {
            [weakSelf.messages addObject:message];
        }
    });
}

#pragma mark - Private methods

- (void)displayInAppViewController:(MEInAppMessage *)message
                    viewController:(MEIAMViewController *)meiamViewController {
    NSPredicate *isKeyWindow = [NSPredicate predicateWithFormat:@"isKeyWindow == YES"];
    self.originalWindow = [[[UIApplication sharedApplication] windows] filteredArrayUsingPredicate:isKeyWindow].firstObject;

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

- (void)closeInAppWithCompletionHandler:(_Nullable EMSCompletion)completionHandler {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.iamWindow.rootViewController dismissViewControllerAnimated:YES
                                                                  completion:^{
                                                                      if (weakSelf.currentInAppMessage && weakSelf.timestampProvider) {
                                                                          [weakSelf.inAppLog setOnScreenTimeEnd:[weakSelf.timestampProvider provideTimestamp]];
                                                                          EMSLog(weakSelf.inAppLog, LogLevelMetric);
                                                                      }
                                                                      weakSelf.iamWindow.windowLevel = UIWindowLevelNormal;
                                                                      weakSelf.iamWindow.frame = CGRectMake(0, 0, 0, 0);
                                                                      weakSelf.iamWindow = nil;

                                                                      [weakSelf.originalWindow makeKeyAndVisible];
                                                                      weakSelf.originalWindow = nil;

                                                                      MEInAppMessage *message = weakSelf.messages.firstObject;
                                                                      if (message) {
                                                                          [weakSelf.messages removeObject:message];
                                                                          [weakSelf showMessage:message
                                                                              completionHandler:nil];
                                                                      }
                                                                      if (completionHandler) {
                                                                          completionHandler();
                                                                      }
                                                                  }];
    });
}

@end
