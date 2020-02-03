//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAMJSCommandFactory.h"
#import "MEIAMRequestPushPermission.h"
#import "MEIAMOpenExternalLink.h"
#import "MEIAMClose.h"
#import "MEIAMTriggerAppEvent.h"
#import "MEIAMButtonClicked.h"
#import "MEIAMTriggerMEEvent.h"

@implementation MEIAMJSCommandFactory

- (instancetype)initWithMEIAM:(id <MEIAMProtocol>)meIam
        buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository {
    if (self = [super init]) {
        _meIam = meIam;
        _buttonClickRepository = buttonClickRepository;
    }
    return self;
}

- (id <MEIAMJSCommandProtocol>)commandByName:(NSString *)name {
    id <MEIAMJSCommandProtocol> command;
    if ([name isEqualToString:MEIAMRequestPushPermission.commandName]) {
        command = [MEIAMRequestPushPermission new];
    } else if ([name isEqualToString:MEIAMOpenExternalLink.commandName]) {
        command = [MEIAMOpenExternalLink new];
    } else if ([name isEqualToString:MEIAMClose.commandName]) {
        command = [[MEIAMClose alloc] initWithMEIAM:self.meIam];
    } else if ([name isEqualToString:MEIAMTriggerAppEvent.commandName]) {
        command = [[MEIAMTriggerAppEvent alloc] initWithInAppMessageHandler:[self.meIam eventHandler]];
    } else if ([name isEqualToString:MEIAMButtonClicked.commandName]) {
        command = [[MEIAMButtonClicked alloc] initWithInAppMessage:[self.meIam currentInAppMessage]
                                                        repository:self.buttonClickRepository
                                                      inAppTracker:self.meIam.inAppTracker];
    } else if ([name isEqualToString:MEIAMTriggerMEEvent.commandName]) {
        command = [MEIAMTriggerMEEvent new];
    }
    return command;
}

@end