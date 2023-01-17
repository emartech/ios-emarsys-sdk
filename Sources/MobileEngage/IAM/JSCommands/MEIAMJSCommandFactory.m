//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEIAMJSCommandFactory.h"
#import "MEIAMRequestPushPermission.h"
#import "MEIAMOpenExternalLink.h"
#import "MEIAMClose.h"
#import "MEIAMTriggerAppEvent.h"
#import "MEIAMButtonClicked.h"
#import "MEIAMTriggerMEEvent.h"
#import "MEIAMCopyToClipboard.h"

@implementation MEIAMJSCommandFactory

- (instancetype)initWithMEIAM:(id <MEIAMProtocol>)meIam
        buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
         appEventHandlerBlock:(EMSEventHandlerBlock)appEventHandlerBlock
                closeProtocol:(id <EMSIAMCloseProtocol>)closeProtocol
                   pasteboard:(UIPasteboard *)pasteboard {
    NSParameterAssert(meIam);
    NSParameterAssert(appEventHandlerBlock);
    NSParameterAssert(closeProtocol);
    NSParameterAssert(pasteboard);

    if (self = [super init]) {
        _meIam = meIam;
        _buttonClickRepository = buttonClickRepository;
        _appEventHandlerBlock = appEventHandlerBlock;
        _closeProtocol = closeProtocol;
        _pasteboard = pasteboard;
    }
    return self;
}

- (id <MEIAMJSCommandProtocol>)commandByName:(NSString *)name {
    id <MEIAMJSCommandProtocol> command;
    if ([name isEqualToString:MEIAMRequestPushPermission.commandName]) {
        command = [MEIAMRequestPushPermission new];
    } else if ([name isEqualToString:MEIAMOpenExternalLink.commandName]) {
        command = [[MEIAMOpenExternalLink alloc] initWithApplication:[UIApplication sharedApplication]];
    } else if ([name isEqualToString:MEIAMClose.commandName]) {
        command = [[MEIAMClose alloc] initWithEMSIAMCloseProtocol:self.closeProtocol];
    } else if ([name isEqualToString:MEIAMTriggerAppEvent.commandName]) {
        command = [[MEIAMTriggerAppEvent alloc] initWithEventHandler:self.appEventHandlerBlock];
    } else if ([name isEqualToString:MEIAMButtonClicked.commandName]) {
        command = [[MEIAMButtonClicked alloc] initWithInAppMessage:self.inAppMessage ? self.inAppMessage : [self.meIam currentInAppMessage]
                                                        repository:self.buttonClickRepository
                                                      inAppTracker:self.meIam.inAppTracker];
    } else if ([name isEqualToString:MEIAMTriggerMEEvent.commandName]) {
        command = [MEIAMTriggerMEEvent new];
    } else if ([name isEqualToString:MEIAMCopyToClipboard.commandName]) {
        command = [[MEIAMCopyToClipboard alloc] initWithPasteboard:self.pasteboard];
    }
    return command;
}

@end